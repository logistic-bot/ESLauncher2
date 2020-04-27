use anyhow::Result;
use flate2::read::GzDecoder;
use std::ffi::OsStr;
use std::fs::{create_dir, File};
use std::path::PathBuf;
use tar::Archive;
use zip_extensions::zip_extract;

pub fn unpack(archive_file: &PathBuf, destination: &PathBuf) -> Result<()> {
    info!(
        "Extracting {} to {}",
        archive_file.to_string_lossy(),
        destination.to_string_lossy()
    );
    match archive_file.extension().and_then(OsStr::to_str) {
        Some("gz") => {
            let file = File::open(archive_file)?;
            let decompressed = GzDecoder::new(file);
            let mut a = Archive::new(decompressed);
            a.unpack(destination)?;
        }
        Some("zip") => {
            if !destination.exists() {
                create_dir(destination)?;
            }
            zip_extract(archive_file, destination)?;
        }
        _ => panic!("Unsupported archive!"),
    };
    Ok(())
}
