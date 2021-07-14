//! Autogenerated weights for polkadex_ocex
//!
//! THIS FILE WAS AUTO-GENERATED USING THE SUBSTRATE BENCHMARK CLI VERSION 3.0.0
//! DATE: 2021-07-14, STEPS: `[20, ]`, REPEAT: 30, LOW RANGE: `[]`, HIGH RANGE: `[]`
//! EXECUTION: Some(Wasm), WASM-EXECUTION: Compiled, CHAIN: Some("dev"), DB CACHE: 128

// Executed Command:
// ./target/release/polkadex-node
// benchmark
// --chain
// dev
// --execution
// wasm
// --wasm-execution
// compiled
// --pallet
// *
// --extrinsic
// *
// --steps
// 20
// --repeat
// 30
// --raw
// --output
// ./benchmarking


#![allow(unused_parens)]
#![allow(unused_imports)]

use frame_support::{traits::Get, weights::Weight};
use sp_std::marker::PhantomData;

/// Weight functions for polkadex_ocex.
pub trait WeightInfo {
    fn deposit() -> Weight;
    fn withdraw() -> Weight;
    fn register() -> Weight;
    fn add_proxy() -> Weight;
    fn remove_proxy() -> Weight;
    fn release() -> Weight;
}

/// Weight functions for polkadex_ocex.
pub struct PalletWeightInfo<T>(PhantomData<T>);

impl<T: frame_system::Config> WeightInfo for PalletWeightInfo<T> {
    fn deposit() -> Weight {
        (82_790_000 as Weight)
            .saturating_add(T::DbWeight::get().reads(2 as Weight))
            .saturating_add(T::DbWeight::get().writes(2 as Weight))
    }
    fn withdraw() -> Weight {
        (18_398_000 as Weight)
    }
    fn register() -> Weight {
        (37_017_000 as Weight)
            .saturating_add(T::DbWeight::get().reads(3 as Weight))
            .saturating_add(T::DbWeight::get().writes(3 as Weight))
    }
    fn add_proxy() -> Weight {
        (34_188_000 as Weight)
            .saturating_add(T::DbWeight::get().reads(1 as Weight))
            .saturating_add(T::DbWeight::get().writes(1 as Weight))
    }
    fn remove_proxy() -> Weight {
        (30_073_000 as Weight)
            .saturating_add(T::DbWeight::get().reads(1 as Weight))
            .saturating_add(T::DbWeight::get().writes(1 as Weight))
    }
    fn release() -> Weight {
        (89_129_000 as Weight)
            .saturating_add(T::DbWeight::get().reads(3 as Weight))
            .saturating_add(T::DbWeight::get().writes(2 as Weight))
    }
}
