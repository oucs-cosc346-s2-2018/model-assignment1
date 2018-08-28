//
//  main.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 18/06/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

// TODO create your instance of your library here
var library:MMCollection? = nil
var last = MMResultSet()

// The while-loop below implements a basic command line interface. Some
// examples of the (intended) commands are as follows:
//
// load foo.json bar.json
//  from the current directory load both foo.json and bar.json and
//  merge the results
//
// list foo bar baz
//  results in a set of files with metadata containing foo OR bar OR baz
//
// add 3 foo bar
//  using the results of the previous list, add foo=bar to the file
//  at index 3 in the list
//
// add 3 foo bar baz qux
//  using the results of the previous list, add foo=bar and baz=qux
//  to the file at index 3 in the list
//
// Feel free to extend these commands/errors as you need to.
while let line = prompt("> "){
    var commandString : String = ""
    var parts = line.split(separator: " ").map({String($0)})
    var command: MMCommand
    
    do{
        guard parts.count > 0 else {
            throw MMCliError.noCommand
        }
        
        commandString = parts.removeFirst();
        
        switch(commandString){
        case "load":
            command = LoadCommand(paths: parts)
            break
         case "list", "add", "set", "del", "save-search", "save":
            command = UnimplementedCommand()
            break
        case "help":
            command = HelpCommand()
            break
        case "quit":
            command = QuitCommand()
            break
        default:
            throw MMCliError.unknownCommand
        }
        // try execute the command and catch any thrown errors below
        try command.execute()
        
        // if there are any results from the command, print them out here
        if let results = command.results {
            results.show()
            last = results
        }
    }catch MMCliError.noCommand {
        print("No command given -- see \"help\" for details.")
    }catch MMCliError.unknownCommand {
        print("Command \"\(commandString)\" not found -- see \"help\" for details.")
    }catch MMCliError.invalidParameters {
        print("Invalid parameters for \"\(commandString)\" -- see \"help\" for details.")
    }catch MMCliError.unimplementedCommand {
        print("The \"\(commandString)\" command is not implemented.")
    }catch MMCliError.missingResultSet {
        print("No previous results to work from.")
    }
}
