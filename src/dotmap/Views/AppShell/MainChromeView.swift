import SwiftUI

// TODO: Replace mocked content blocks with production data-backed content.
struct MainChromeView: View {
    private var leadingTopAccessoryWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            topChrome
            stubContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DotmapColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: DotmapRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DotmapRadius.xl, style: .continuous)
                .stroke(DotmapColor.borderDefault, lineWidth: 1)
        )
    }

    private var topChrome: some View {
        HStack(spacing: DotmapSpacing.sm) {
            Color.clear
                .frame(width: leadingTopAccessoryWidth, height: 1)

            Text("Home")
                .dotmapTextStyle(DotmapTypography.bodyStrong)
                .foregroundStyle(DotmapColor.textInverse)

            Spacer(minLength: 0)

            HStack(spacing: DotmapSpacing.xl) {
                HStack(spacing: DotmapSpacing.xs) {
                    DotmapIconView(
                        icon: .search,
                        size: DotmapSpacing.s14,
                        tint: DotmapColor.textMuted
                    )
                    Text("Search")
                        .dotmapTextStyle(DotmapTypography.caption)
                        .foregroundStyle(DotmapColor.textMuted)
                }

                HStack(spacing: DotmapSpacing.xxs) {
                    DotmapIconView(icon: .command, size: 12, tint: DotmapColor.textMuted)
                    Text("K")
                        .dotmapTextStyle(DotmapTypography.caption)
                        .foregroundStyle(DotmapColor.textMuted)
                }
                .padding(.horizontal, DotmapSpacing.xs)
                .padding(.vertical, DotmapSpacing.xxs)
                .background(DotmapColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous)
                        .stroke(DotmapColor.borderFocus, lineWidth: 1)
                )
            }
            .padding(.horizontal, DotmapSpacing.xs)
            .padding(.vertical, DotmapSpacing.xxs)
            .frame(width: 122, height: 20)
            .background(DotmapColor.fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous)
                    .stroke(DotmapColor.borderField, lineWidth: 1)
            )
        }
        .padding(.horizontal, AppShellChromeMetrics.topChromeHorizontalPadding)
        .padding(.vertical, DotmapSpacing.sm)
        .frame(height: AppShellChromeMetrics.topChromeHeight)
        .background(DotmapColor.appBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(DotmapColor.borderDefault)
                .frame(height: 1)
        }
    }

    private var stubContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotmapSpacing.lg) {
                stubBlock(title: "Shell Layout Stub")
                stubBlock(title: "Main Content Stub")
                stubBlock(title: "Detail Surfaces Stub")
            }
            .frame(maxWidth: 760, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(DotmapSpacing.lg)
            .padding(.top, DotmapSpacing.sm)
        }
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func stubBlock(title: String) -> some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.sm) {
            Text(title)
                .dotmapTextStyle(DotmapTypography.bodyStrong)
                .foregroundStyle(DotmapColor.textPrimary)

            RoundedRectangle(cornerRadius: DotmapRadius.lg, style: .continuous)
                .fill(DotmapColor.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: DotmapRadius.lg, style: .continuous)
                        .stroke(DotmapColor.borderDefault, lineWidth: 1)
                )
                .frame(height: 124)
        }
    }
}

extension MainChromeView {
    func leadingTopAccessoryWidth(_ width: CGFloat) -> MainChromeView {
        var copy = self
        copy.leadingTopAccessoryWidth = width
        return copy
    }
}
