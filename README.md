# COSC346 - Assignment 1 Sample Solution

## Table of Contents

* [Overview](#overview)
   * [Git Import Option 1](#option-1)
   * [Git Import Option 2](#option-2)
* [Design](#design)
   * [Object Oriented Principles](#object-oriented-principles)
   * [Design Patterns](#design-patterns)
* [Testing](#testing)
* [Limitations](#limitations)

## Overview

This repository contains a sample solution to the first assignment. There are a
couple of different ways to get this working with your assignment 2 repos.

If you feel that you want to fix any problems with the code feel free to do so,
but keep in mind that it's not really the point of the second assignment.

### Option 1

1. Download the zip file
2. Extract into your Assignment 2 repo
3. Add/Commit/Push these files.

This will work, but you'll lose the history.

### Option 2

1. git clone the repo
2. git remote set-url asgn2 <enter your repo url here>
3. git push asgn2 master

This will preserve the history, but requires that you don't have *any* history
in your repo.

## Design

### Object Oriented Principles

1. Composition (the collection is composed of Importer/Exporter and Indexer)
2. Inheritance (the different file types inherit from a base file class that does most of the work -- specialisation)
3. Polymorphism (the collection only cares about MMFiles yet each are a different concrete instance, some methods in the collection/index)
4. Coupling (the indexer isn't dependent on the internals of the files)
5. Cohesion (the indexing has been separated from the collection, the import and export are separate from eachother and the collection)
6. Abstraction (the use of protocols)
7. Encapsulation (visibility is set to be as restrictive as possible where appropriate, each object has a clear set of responsibilities)

### Design Patterns

The following design patterns make an appearence in the application.

1. Command (for handling the different commands)
2. MVC (the Metadata/File objects are the model, the view is the ResultSet and the controller is the collection/index) 
3. Decorator (in the validation of metadata)
4. Factory (in creating the files from the JSON data)
5. Facade (the collection could be viewed as a facade for the index/import/export)

The following design patterns could be used in the project.

1. **Observer** used to notify the index that files/metadata/terms have been updated/changed
2. **Strategy** used to select the import/export based on serialisation methods
3. **Strategy** used to select the specific validator for checking that the file is valid (beyond the keyword validator at present)

## Testing

Done via unit tests. The current code coverage metric is around 86% (which
could be better) but it covers the majority of the applicaiton.

Each module has it's own test cases, for example, the Importer is tested
separetely from the other classes in the system.

Have a look through the test cases (especially the
MediaLibraryManagerTests.swift) as they contain examples of how to generate
commands that you may find useful for Assignment 2)

## Limitations

* The collection only searches for the *values* of the metadata, and not the keywords
