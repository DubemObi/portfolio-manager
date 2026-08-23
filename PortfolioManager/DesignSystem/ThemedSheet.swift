//
//  ThemedSheet.swift
//  PortfolioManager
//
//  Wraps sheet content so it re-reads the theme directly, rather than
//  relying on inheriting .preferredColorScheme from an ancestor - sheets
//  don't reliably pick up a theme change made while they're already open.
//  Wrap any .sheet's content in this, and it always stays in sync.
//

import SwiftUI

struct ThemedSheet<SheetContent: View>: View {
    @AppStorage("themeToggle") private var themeToggleRaw: String = ThemeToggle.light.rawValue
    private let content: SheetContent

    init(@ViewBuilder content: () -> SheetContent) {
        self.content = content()
    }

    var body: some View {
        content
            .preferredColorScheme((ThemeToggle(rawValue: themeToggleRaw) ?? .light).colorScheme)
    }
}
