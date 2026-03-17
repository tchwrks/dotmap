import SwiftUI

struct MainChromeView: View {
    let title: String
    let leadingTopAccessoryWidth: CGFloat

    var body: some View {
        topChrome
    }

    private var topChrome: some View {
        HStack(spacing: DotmapSpacing.sm) {
            Color.clear
                .frame(width: leadingTopAccessoryWidth, height: 1)

            Text(title)
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
}
