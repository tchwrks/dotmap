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
    ConfigFileItem(name: ".zshenv", children: []),
    ConfigFileItem(name: ".bashrc", children: []),
    ConfigFileItem(name: ".bash_profile", children: []),
    ConfigFileItem(name: ".profile", children: []),
    ConfigFileItem(name: ".zlogin", children: []),
//    ConfigFileItem(name: ".zlogout", children: []),
//    ConfigFileItem(name: ".zsh_aliases", children: []),
//    ConfigFileItem(name: ".zsh_exports", children: []),
//    ConfigFileItem(name: ".zsh_paths", children: []),
//    ConfigFileItem(name: ".zsh_functions", children: []),
//    ConfigFileItem(name: ".zsh_plugins", children: []),
//    ConfigFileItem(name: ".zsh_prompt", children: []),
]
