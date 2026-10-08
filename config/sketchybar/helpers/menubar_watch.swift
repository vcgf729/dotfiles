// Slides SketchyBar out of the way while the macOS menu bar is revealed,
// and keeps the cursor off the top edge over the notch so going to Atoll
// doesn't pop the macOS menu bar.
import AppKit

let sketchybar = "/opt/homebrew/bin/sketchybar"
let shownOffset = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "2"
let notchPad: CGFloat = 40   // treat a bit either side of the notch as "notch"
var hidden = false

// Atoll: when its panel is open, widen the bar's notch gap so the pills wrap around it.
// Tunables live in notchguard.conf (re-read on every open/close, so no rebuild needed).
let confPath = NSString(string: "~/.config/sketchybar/helpers/notchguard.conf").expandingTildeInPath
// Parsed once a second (see reloadConf) instead of on every mouse move.
var confValues: [String: String] = [:]
func reloadConf() {
  guard let text = try? String(contentsOfFile: confPath, encoding: .utf8) else { return }
  var v: [String: String] = [:]
  for line in text.split(separator: "\n") {
    let kv = line.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
    if kv.count == 2, !kv[0].hasPrefix("#") { v[kv[0]] = kv[1] }
  }
  confValues = v
}
func confText(_ key: String) -> String? { confValues[key] }
func conf(_ key: String, _ fallback: Double) -> Double { confValues[key].flatMap(Double.init) ?? fallback }
var atollOpenWidth: CGFloat { CGFloat(conf("atoll_open_width", 690)) }
let atollOpenHeight: CGFloat = 200   // approx. height of the open panel
let gapClosed = 210
var atollOpen = false
var pendingClose: DispatchWorkItem?

func setAtoll(_ open: Bool) {
  guard open != atollOpen else { return }
  atollOpen = open
  pendingClose?.cancel()
  if open {
    let work = DispatchWorkItem {
      let frames = Int(conf("open_frames", 36))
      sb(["--animate", confText("open_curve") ?? "tanh", "\(frames)",
          "--bar", "notch_width=\(Int(atollOpenWidth) + 20)"])
    }
    pendingClose = work
    DispatchQueue.main.asyncAfter(deadline: .now() + conf("open_delay", 0), execute: work)
  } else {
    // Wait for Atoll to finish shrinking before the pills slide back in,
    // so they never slip underneath it.
    let work = DispatchWorkItem {
      let frames = Int(conf("close_frames", 72))
      sb(["--animate", confText("close_curve") ?? "sin", "\(frames)", "--bar", "notch_width=\(gapClosed)"])
    }
    pendingClose = work
    DispatchQueue.main.asyncAfter(deadline: .now() + conf("close_delay", 0.35), execute: work)
  }
}

func sb(_ args: [String]) {
  let p = Process()
  p.executableURL = URL(fileURLWithPath: sketchybar)
  p.arguments = args
  try? p.run()
}

// Horizontal range of the notch on this screen, if it has one.
func notchRange(_ s: NSScreen, pad: CGFloat = notchPad) -> ClosedRange<CGFloat>? {
  guard let l = s.auxiliaryTopLeftArea, let r = s.auxiliaryTopRightArea else { return nil }
  return (s.frame.minX + l.maxX - pad)...(s.frame.minX + r.minX + pad)
}

// Small log of why the bar's gap changed: /tmp/notchguard.log
func log(_ msg: String) {
  let line = "\(Date().formatted(date: .omitted, time: .standard)) \(msg)\n"
  let url = URL(fileURLWithPath: "/tmp/notchguard.log")
  if let h = try? FileHandle(forWritingTo: url) { h.seekToEndOfFile(); h.write(line.data(using: .utf8)!); try? h.close() }
  else { try? line.write(to: url, atomically: true, encoding: .utf8) }
}
var hoverStart: Date?

// Right edge of the Apple logo + workspace numbers (written by guard_zone.sh)
var leftGuard: CGFloat = 0
func readLeftGuard() {
  let v = (try? String(contentsOfFile: "/tmp/sketchybar_guard_left", encoding: .utf8))
    .flatMap { Double($0.trimmingCharacters(in: .whitespacesAndNewlines)) } ?? 0
  if CGFloat(v) != leftGuard { leftGuard = CGFloat(v); rebuildZones() }
}

// Places where the top edge should NOT reveal the macOS menu bar.
func guardRanges(_ s: NSScreen) -> [ClosedRange<CGFloat>] {
  var r: [ClosedRange<CGFloat>] = []
  if let n = notchRange(s) { r.append(n) }
  if leftGuard > 0 { r.append(s.frame.minX...(s.frame.minX + leftGuard)) }
  return r
}

func check(_ dy: CGFloat = 0) {
  let m = NSEvent.mouseLocation
  guard let screen = NSScreen.screens.first(where: { NSMouseInRect(m, $0.frame, false) }) else { return }
  let fromTop = screen.frame.maxY - m.y
  let inNotch = notchRange(screen)?.contains(m.x) ?? false
  let inGuard = guardRanges(screen).contains { $0.contains(m.x) }

  // Track Atoll: opens when hovering the notch, closes once the mouse leaves the open panel.
  if notchRange(screen) != nil {
    let fromCenter = abs(m.x - screen.frame.midX)
    // "Open" only once the mouse has rested on the notch itself (not the padded
    // guard zone) for as long as Atoll needs before it opens.
    let onNotch = (notchRange(screen, pad: CGFloat(conf("atoll_hover_pad", 4)))?.contains(m.x) ?? false) && fromTop <= 32
    if !atollOpen {
      if onNotch {
        if hoverStart == nil { hoverStart = Date() }
        if Date().timeIntervalSince(hoverStart!) >= conf("atoll_hover_delay", 0.12) {
          hoverStart = nil
          log("open  (mouse on notch at x=\(Int(m.x)) y=\(Int(fromTop)) from top)")
          setAtoll(true)
        }
      } else { hoverStart = nil }
    } else if fromCenter > atollOpenWidth / 2 + 8 || fromTop > atollOpenHeight + 8 {
      log("close (mouse left Atoll at x=\(Int(m.x)) y=\(Int(fromTop)) from top)")
      setAtoll(false)
    }
  }

  // Guard zone: 12pt deep, plus look-ahead so fast upward flicks are caught
  // before they reach the edge (dy < 0 means moving up).
  let predicted = fromTop + min(dy, 0) * 2
  if inGuard && (fromTop <= 12 || predicted <= 12) {
    // Keep the cursor 14pt below the edge: still on the notch (Atoll), but off the edge.
    let primaryH = NSScreen.screens[0].frame.height
    CGWarpMouseCursorPosition(CGPoint(x: m.x, y: primaryH - screen.frame.maxY + 14))
    CGAssociateMouseAndMouseCursorPosition(1)
    return
  }
  if !hidden && fromTop <= 3 && !inGuard {
    hidden = true
    sb(["--animate", "tanh", "10", "--bar", "y_offset=-60"])
  } else if hidden && fromTop > 50 {
    hidden = false
    sb(["--animate", "tanh", "12", "--bar", "y_offset=\(shownOffset)"])
  }
}


// ---- Strict notch guard (needs Accessibility) ----
// An event tap sees every mouse move *before* the system acts on it, so the
// cursor is clamped below the edge over the notch and never touches it.
struct NotchZone { let xRange: ClosedRange<CGFloat>; let top: CGFloat }  // CG (top-left) coords
var zones: [NotchZone] = []
var tap: CFMachPort?

func rebuildZones() {
  let primaryH = NSScreen.screens[0].frame.height
  zones = NSScreen.screens.flatMap { s in
    guardRanges(s).map { NotchZone(xRange: $0, top: primaryH - s.frame.maxY) }
  }
}

let tapCallback: CGEventTapCallBack = { _, type, event, _ in
  if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
    if let t = tap { CGEvent.tapEnable(tap: t, enable: true) }
    return Unmanaged.passUnretained(event)
  }
  var p = event.location
  for z in zones where z.xRange.contains(p.x) && p.y < z.top + 14 && p.y > z.top - 50 {
    p.y = z.top + 14
    event.location = p
    CGWarpMouseCursorPosition(p)
    break
  }
  return Unmanaged.passUnretained(event)
}

func startTap() -> Bool {
  guard tap == nil else { return true }
  let mask = [CGEventType.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
    .reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }
  guard let t = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap,
                                  options: .defaultTap, eventsOfInterest: mask,
                                  callback: tapCallback, userInfo: nil) else { return false }
  tap = t
  CFRunLoopAddSource(CFRunLoopGetMain(), CFMachPortCreateRunLoopSource(nil, t, 0), .commonModes)
  CGEvent.tapEnable(tap: t, enable: true)
  return true
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let eventSource = CGEventSource(stateID: .combinedSessionState)
eventSource?.localEventsSuppressionInterval = 0  // no cursor freeze after a nudge
NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) { e in check(e.deltaY) }  // deltaY < 0 = moving up
Timer.scheduledTimer(withTimeInterval: 1.0 / 20, repeats: true) { _ in check() }  // fallback
readLeftGuard()
rebuildZones()
reloadConf()
Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in readLeftGuard(); reloadConf() }
NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification,
                                       object: nil, queue: .main) { _ in rebuildZones() }
// Ask for Accessibility once; keep retrying until it's granted.
let trusted = AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
if !(trusted && startTap()) {
  Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { t in
    if AXIsProcessTrusted() && startTap() { t.invalidate() }
  }
}
app.run()
