import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_FunctionImplementationFactory: XCTestCase {
    func testDeclaration() throws {
        let variablePrefix = "functionName"

        let protocolFunctionDeclaration = try FunctionDeclSyntax(
            "func foo()"
        ) {}

        let result = FunctionImplementationFactory().declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: protocolFunctionDeclaration
        )

        assertBuildResult(
            result,
            """
            func foo() {
                functionNameCallsCount += 1
                functionNameClosure?()
            }
            """
        )
    }
    
    func testDeclarationNewVersion() throws {
        let variablePrefix = "fetchDistricts"

        let protocolFunctionDeclaration = try FunctionDeclSyntax(
            "func fetchDistricts(forCityCode code: String, location: Location)"
        ) {}

        let result = FunctionImplementationFactory().declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: protocolFunctionDeclaration
        )

        assertBuildResult(
            result,
            """
            func fetchDistricts(forCityCode code: String, location: Location) {
                invokedList.append(.fetchDistricts(code: code, location: location))

            }
            """
        )
    }

    func testDeclarationArguments() throws {
        let variablePrefix = "func_name"

        let protocolFunctionDeclaration = try FunctionDeclSyntax(
            "func foo(text: String, count: Int)"
        ) {}

        let result = FunctionImplementationFactory().declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: protocolFunctionDeclaration
        )

        assertBuildResult(
            result,
            """
            func foo(text: String, count: Int) {
                func_nameCallsCount += 1
                func_nameReceivedArguments = (text, count)
                func_nameReceivedInvocations.append((text, count))
                func_nameClosure?(text, count)
            }
            """
        )
    }

    func testDeclarationReturnValue() throws {
        let variablePrefix = "funcName"

        let protocolFunctionDeclaration = try FunctionDeclSyntax(
            "func foo() -> (text: String, tuple: (count: Int?, Date))"
        ) {}

        let result = FunctionImplementationFactory().declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: protocolFunctionDeclaration
        )

        assertBuildResult(
            result,
            """
            func foo() -> (text: String, tuple: (count: Int?, Date)) {
                funcNameCallsCount += 1
                if funcNameClosure != nil {
                    return funcNameClosure!()
                } else {
                    return funcNameReturnValue
                }
            }
            """
        )
    }

    func testDeclarationReturnValueAsyncThrows() async throws {
        let variablePrefix = "foo"

        let protocolFunctionDeclaration = try FunctionDeclSyntax(
            "func foo(_ bar: String) async throws -> (text: String, tuple: (count: Int?, Date))"
        ) {}

        let result = FunctionImplementationFactory().declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: protocolFunctionDeclaration
        )

        assertBuildResult(
            result,
            """
            func foo(_ bar: String) async throws -> (text: String, tuple: (count: Int?, Date)) {
                fooCallsCount += 1
                fooReceivedBar = (bar)
                fooReceivedInvocations.append((bar))
                if fooClosure != nil {
                    return try await fooClosure!(bar)
                } else {
                    return fooReturnValue
                }
            }
            """
        )
    }
}
