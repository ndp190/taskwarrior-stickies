//
//  StickyWindow.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import SwiftUI
import AppKit

class StickyWindow: NSWindow {
    private let sticky: Sticky
    private let taskService: TaskService
    private let dataManager: DataManager
    private var viewModel: StickyViewModel?
    
    init(sticky: Sticky, taskService: TaskService, dataManager: DataManager) {
        self.sticky = sticky
        self.taskService = taskService
        self.dataManager = dataManager
        
        super.init(
            contentRect: NSRect(origin: sticky.position, size: sticky.size),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = sticky.title
        self.level = sticky.alwaysOnTop ? .floating : .normal
        self.alphaValue = sticky.transparency
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        
        let viewModel = StickyViewModel(sticky: sticky, taskService: taskService, dataManager: dataManager)
        self.viewModel = viewModel
        
        let hostingView = NSHostingView(rootView: StickyView(viewModel: viewModel))
        self.contentView = hostingView
        
        // Observe window state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidMove(_:)),
            name: NSWindow.didMoveNotification,
            object: self
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize(_:)),
            name: NSWindow.didResizeNotification,
            object: self
        )
    }
    
    @objc private func windowDidMove(_ notification: Notification) {
        DispatchQueue.main.async {
            Task {
                do {
                    _ = try await self.dataManager.updateStickyWindowFrame(
                        id: self.sticky.id,
                        position: self.frame.origin,
                        size: self.frame.size
                    )
                } catch {
                    print("Failed to save window position: \(error)")
                }
            }
        }
    }
    
    @objc private func windowDidResize(_ notification: Notification) {
        DispatchQueue.main.async {
            Task {
                do {
                    _ = try await self.dataManager.updateStickyWindowFrame(
                        id: self.sticky.id,
                        position: self.frame.origin,
                        size: self.frame.size
                    )
                } catch {
                    print("Failed to save window size: \(error)")
                }
            }
        }
    }
    
    func updateTransparency(_ transparency: Double) {
        self.alphaValue = transparency
    }
    
    func updateAlwaysOnTop(_ alwaysOnTop: Bool) {
        self.level = alwaysOnTop ? .floating : .normal
    }
    
    func refreshTasks() async {
        await viewModel?.refreshTasks()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
