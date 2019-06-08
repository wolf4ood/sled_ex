use rustler::resource::ResourceArc;
use rustler::{Encoder, Env, NifResult, Term};
use sled::{Config, ConfigBuilder, Db};
use std::io::Write;

use crate::error::SledExError;
use crate::SledExResult;

use crate::atoms;
use rustler::types::binary::{Binary, OwnedBinary};

pub struct DBHandle(sled::Db);

impl DBHandle {
    fn new(config: Config) -> SledExResult<DBHandle> {
        let db = Db::start(config)?;
        Ok(DBHandle(db))
    }

    fn set(&self, key: Binary, value: Binary) -> SledExResult<()> {
        self.0.set(key.as_slice(), value.as_slice())?;

        Ok(())
    }

    fn get(&self, key: Binary) -> SledExResult<OwnedBinary> {
        let val = self
            .0
            .get(key.as_slice())?
            .ok_or_else(|| SledExError::NotFound)?;

        let mut bin = OwnedBinary::new(val.len()).unwrap();
        bin.as_mut_slice().write(&val)?;

        Ok(bin)
    }

    fn del(&self, key: Binary) -> SledExResult<()> {
        self.0.del(key.as_slice())?;
        Ok(())
    }
}

pub fn start_default<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let path: String = args[0].decode()?;
    let config = ConfigBuilder::new().path(path).build();
    let db = DBHandle::new(config)?;
    let resource = ResourceArc::new(db);

    Ok((atoms::ok(), resource).encode(env))
}

pub fn set<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let db: ResourceArc<DBHandle> = args[0].decode()?;

    let key: Binary = args[1].decode()?;
    let val: Binary = args[2].decode()?;

    db.set(key, val)?;

    Ok(atoms::ok().encode(env))
}

pub fn get<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let db: ResourceArc<DBHandle> = args[0].decode()?;

    let key: Binary = args[1].decode()?;

    Ok((atoms::ok(), db.get(key)?.release(env).encode(env)).encode(env))
}

pub fn del<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let db: ResourceArc<DBHandle> = args[0].decode()?;

    let key: Binary = args[1].decode()?;

    db.del(key)?;

    Ok(atoms::ok().encode(env))
}
