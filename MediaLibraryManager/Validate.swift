//
//  Validate.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 28/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/// A list of possible validation errors.
///
/// - unknownFileType: The validation has encounted an unknown filetype
/// - missingKeyword: Thrown if the keyword validator fails to find the keyword it's looking for
/// - unknownError: Thrown if there are any other errors
enum MMValidationError: Error {
    case unknownFileType
    case missingKeyword(which: String)
    case unknownError(which: Error)
}

/// The generic validator protocol
protocol Validator {
    /// Perform the validators validation rules
    ///
    /// - Parameter data: the list of metadata to validate
    /// - Throws: a MMValidationError if the validation fails
    func validate(data: [MMMetadata]) throws
}

/// Validates a list of metadata looking through the keywords
class KeywordValidator: Validator, CustomStringConvertible {

    /// The keyword to look for
    var keyword: String

    /// A human readable description of the object
    var description: String {
        return self.keyword
    }

    /// Create a new instance
    ///
    /// - Parameter keyword: The keyword to look for
    init(keyword: String) {
        self.keyword = keyword
    }

    /// Given a list of metadata, find the keyword. If it's not found, throw an error.
    ///
    /// - Parameter data: the list of metadata to look through
    /// - Throws: missingKeyword if we fail to find the keyword in the list
    func validate(data: [MMMetadata]) throws {
        var valid = false
        // swiftlint:disable:next identifier_name
        for md in data where md.keyword == self.keyword {
            valid = true
        }
        if !valid {
            throw MMValidationError.missingKeyword(which: self.keyword)
        }
    }
}

/// Combines a set of validators into a validation suite
class ValidatorSuite {

    /// The list of validators that we need to deal with.
    var validators: [Validator] = []

    /// Add a validator into the list of validators
    ///
    /// - Parameter validator: the validator to add
    func add(validator: Validator) {
        self.validators.append(validator)
    }

    /// Performs the validation of the metadata
    ///
    /// - Parameter data: The metadata
    /// - Returns: a (possibly empty) list of errors encountered
    func validate(data: [MMMetadata]) -> [MMValidationError] {
        var errors: [MMValidationError] = []
        for validator in validators {
            do {
                try validator.validate(data: data)
            } catch let error as MMValidationError {
                errors.append(error)
            } catch {
                // we're wrapping any other errors up as an instance of MMValidationError
                // I don't think Swift allows you to specify the *type* of error thrown
                errors.append(MMValidationError.unknownError(which: error))
            }
        }
        return errors
    }
}
