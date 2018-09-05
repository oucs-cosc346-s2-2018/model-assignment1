//
//  Validate.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 28/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

// we have a set of business rules (e.g. must have creator, must have resolution)
// these are dependent on the type we're constructing

// also there should be a list of validators for each type of file
//
// I'd expect something like:
//  hasCreator(metadata) && hasResolution(metadata)
// to be checked before we can create the object instance

// the other option is a Builder class that we can give it one of those F structs
// and it'll construct the appropriate type of object

// the first step in validation is to transform the list of key/value pairs into
// a set of Metadata instances

// once we have those metadata instances, we can then look to see if we have
// the correct metadata before we can construct the File

enum MMValidationError: Error {
    case unimplementedValidation
    case unknownFileType
    case missingField(which: String)
}

class KeywordValidator {
    var keyword: String
    init(keyword: String) {
        self.keyword = keyword
    }
    func validate(data: [MMMetadata]) throws {
        var valid = false
        // swiftlint:disable:next identifier_name
        for md in data where md.keyword == self.keyword {
            valid = true
        }
        if !valid {
            throw MMValidationError.missingField(which: self.keyword)
        }
    }
}

class ValidatorSuite {
    var validators: [KeywordValidator]

    init(validators: [KeywordValidator]) {
        self.validators = validators
    }

    convenience init() {
        self.init(validators: [])
    }

    func add(validator: KeywordValidator) {
        self.validators.append(validator)
    }

    func validate(data: [MMMetadata]) -> [MMValidationError] {
        var errors: [MMValidationError] = []
        for validator in validators {
            do {
                try validator.validate(data: data)
            } catch let error as MMValidationError {
                errors.append(error)
            } catch {
                print("\(error)")
            }
        }
        return errors
    }
}
