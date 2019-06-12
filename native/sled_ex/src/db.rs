use crate::error::SledExError;
use crate::SledExResult;
use rustler::resource::ResourceArc;
use rustler::{Encoder, Env, NifResult, Term};
use sled::{Config, ConfigBuilder, Db, IVec, Iter};
use std::io::Write;
use std::sync::Mutex;

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

    fn scan(&self, key: Binary) -> SledExResult<Cursor> {
        let iter = self.0.scan(key.as_slice());

        let eternal_iter: Iter<'static> = unsafe { std::mem::transmute(iter) };

        Ok(Cursor(Mutex::new(eternal_iter)))
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

pub fn scan<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let db: ResourceArc<DBHandle> = args[0].decode()?;

    let key: Binary = args[1].decode()?;

    let cursor = db.scan(key)?;

    let resource = ResourceArc::new(cursor);

    Ok((atoms::ok(), resource).encode(env))
}

pub fn iter_next<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let cursor: ResourceArc<Cursor> = args[0].decode()?;

    match cursor.next() {
        Some(val) => {
            let (k, v) = val?;

            let mut key = OwnedBinary::new(k.len()).unwrap();
            key.as_mut_slice().write(&k).map_err(SledExError::from)?;

            let mut value = OwnedBinary::new(v.len()).unwrap();
            value.as_mut_slice().write(&v).map_err(SledExError::from)?;

            Ok((key.release(env).encode(env), value.release(env).encode(env)).encode(env))
        }
        None => Ok(atoms::done().encode(env)),
    }
}

pub struct Cursor(Mutex<sled::Iter<'static>>);

impl Cursor {
    fn next(&self) -> Option<SledExResult<(Vec<u8>, IVec)>> {
        self.0
            .lock()
            .unwrap()
            .next()
            .map(|v| v.map_err(SledExError::from))
    }
}

unsafe impl Sync for Cursor {}
unsafe impl Send for Cursor {}
