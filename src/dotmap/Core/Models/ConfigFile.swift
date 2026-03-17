//
//  FileTreeModel.swift
//  dotmap
//
//  Created by Noah Davis on 3/16/26.
//
import Foundation

struct ConfigFileItem: Identifiable, Hashable {
    let name: String
    let children: [SourcedFileItem]

    var id: String { name }
    var hasChildren: Bool { !children.isEmpty }
}

struct SourcedFileItem: Identifiable, Hashable {
    let name: String

    var id: String { name }
}

enum ConfigSelection: Hashable {
    case rootFile(String)
    case sourcedBlock(parent: String, block: String)
}

let mockConfigs: [ConfigFileItem] = [
    ConfigFileItem(name: ".zprofile", children: []),
    ConfigFileItem(name: ".zshrc", children: [
        SourcedFileItem(name: "oh-my-zsh"),
        SourcedFileItem(name: "nvm"),
        SourcedFileItem(name: "rbenv"),
    ]),
    ConfigFileItem(name: ".bashrc", children: []),
]
