//
//  SourcedFileRow.swift
//  dotmap
//
//  Created by Noah Davis on 3/16/26.
//

import SwiftUI

struct SourcedFileRow: View {
    let name: String

    var body: some View {
        Text(name)
            .dotmapTextStyle(DotmapTypography.body)
            .foregroundStyle(DotmapColor.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DotmapSpacing.xs)
            .padding(.vertical, DotmapSpacing.xs)
            .contentShape(Rectangle())
    }
}
