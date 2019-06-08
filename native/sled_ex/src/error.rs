use rustler;
use sled;

#[derive(Debug, Error)]
pub enum SledExError {
    #[error(display = "database error: {:?}", _0)]
    Sled(sled::Error),
    #[error(display = "key not found")]
    NotFound,
    #[error(display = "io error: {:?}", _0)]
    IO(std::io::Error),
}

impl From<sled::Error> for SledExError {
    fn from(from: sled::Error) -> SledExError {
        SledExError::Sled(from)
    }
}

impl From<std::io::Error> for SledExError {
    fn from(from: std::io::Error) -> SledExError {
        SledExError::IO(from)
    }
}

impl From<SledExError> for rustler::Error {
    fn from(from: SledExError) -> rustler::Error {
        match from {
            SledExError::NotFound => rustler::Error::Atom("not_found"),
            _ => panic!("not handled"),
        }
    }
}
