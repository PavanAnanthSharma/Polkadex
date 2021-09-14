const {ApiPromise, WsProvider} = require('@polkadot/api');
const {Keyring} = require('@polkadot/keyring');
const {types, rpc} = require('./types')
const SCALAR = 1_000_000_000_000;
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("started main")
    // Instantiate the API
    const provider = new WsProvider('ws://127.0.0.1:9944');

    const api = await ApiPromise.create({provider, types, rpc});
    var currentBlockNumer = 0;
    api.derive.chain.subscribeNewHeads((header) => {
        currentBlockNumer = header.number.toNumber()
    });

    // Subscribe to system events via storage
    api.query.system.events((events) => {
        console.log(`\nReceived ${events.length} events:`);

        // Loop through the Vec<EventRecord>
        events.forEach((record) => {
            // Extract the phase, event and the event types
            const { event, phase } = record;
            const types = event.typeDef;

            // Show what we are busy with
            console.log(`\t${event.section}:${event.method}:: (phase=${phase.toString()})`);

            // Loop through each of the parameters, displaying the type and data
            event.data.forEach((data, index) => {
                console.log(`\t\t\t${types[index].type}: ${data.toString()}`);
            });
        });
    });

    // Constuct the keyring after the API (crypto has an async init)
    const keyring = new Keyring({type: 'sr25519'});

    // Add an account, straight mnemonic
    const ALICE = keyring.addFromUri("//Alice");
    const BOB = keyring.addFromUri("//Bob");
    const DAVE = keyring.addFromUri("//Dave");
    const EVE = keyring.addFromUri("//Eve");
    const FERDIE = keyring.addFromUri("//Ferdie");


    const HELLCAT = keyring.addFromUri("//Hellcat");
    //const REGINA = keyring.addFromUri("//Regina");

    let senders = [ALICE,BOB,DAVE,EVE,FERDIE]
    let receivers = [HELLCAT]


    for (const sender of senders) {
        let inc = 1;
        for (const receiver of receivers) {
            let amount = 100 * inc * SCALAR;
            console.log(`Send ${amount} from ${sender.address} to ${receiver.address} `)
            let transfer = api.tx.balances.transfer(receiver.address,amount);
            let stake = inc;
            await api.tx.polkapool.claimFeelessTransaction(stake, transfer).signAndSend(sender);
            amount++
        }
    }
    await sleep(12000);

    for (const sender of senders) {
        const stakeUserResults = await api.query.polkapool.stakedUsers(sender.address);
        console.log(`Sender: ${sender.address} StakeInfo: `, stakeUserResults.toHuman());
    }



}

const alertErrors = (events, api) => {
    events
        // find/filter for failed events
        // we know that data for system.ExtrinsicFailed is
        // (DispatchError, DispatchInfo)
        .forEach(({event: {data: [err, info]}}) => {
            let error = err
            if (error.isModule) {
                // for module errors, we have the section indexed, lookup
                const decoded = api.registry.findMetaError(error.asModule);
                const {docs, method, section} = decoded;
                console.log(`${section}.${method}: ${docs.join(' ')}`);
            } else {
                // Other, CannotLookup, BadOrigin, no extra info
                console.log(error.toString());
            }
        });
}

main().catch(console.error).finally(() => {
    setTimeout(() => {
        process.exit()
    }, 70000);
});
