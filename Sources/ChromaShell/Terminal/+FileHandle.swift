import Foundation

/// Hoping I won't need this extension with later versions of Foundation that
/// support for API's on linux
extension FileHandle {

    /// Return an iterator over the bytes in the file.
    ///
    /// - returns: An iterator for UInt8 elements.
    func asyncByteIterator() -> _FileHandleAsyncByteIterator {
        return _FileHandleAsyncByteIterator(fileHandle: self)
    }

    struct _FileHandleAsyncByteIterator: AsyncSequence {

        typealias Element = UInt8

        let fileHandle: FileHandle

        init(fileHandle: FileHandle) {
            self.fileHandle = fileHandle
        }

        struct AsyncIterator: AsyncIteratorProtocol {
            typealias Element = UInt8
            let fileHandle: FileHandle

            @available(*, deprecated, message: "Really bad, but works for now")
            mutating func next() async throws -> UInt8? {
                guard let data: Data = try fileHandle.read(upToCount: 1) else {
                    throw AsyncIteratorError.readError
                }
                return data.first
            }
        }

        func makeAsyncIterator() -> AsyncIterator {
            return AsyncIterator(fileHandle: fileHandle)
        }
    }
}

enum AsyncIteratorError: Error {
    case readError
}
