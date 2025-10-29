This Is An Overview Of My Lido Trap

This repository contains an implementation of a Drosera trap designed to monitor Lido’s stETH supply changes on the Hoodi testnet. The trap listens for supply growth events (minting / reward issuance) and determines whether it should respond by instructing a responder contract to forward a small portion of detected rewards to a partner protocol, forming an incentive feedback loop.

The trap is composed of two main components:

Trap Contract A Solidity smart contract that integrates with Drosera’s runtime. It defines the logic for identifying supply growth on the stETH contract by sampling totalSupply() across blocks. The contract exposes a shouldRespond function, which compares previous and current supply samples and decides whether a response is required, and a collect function, which returns the sampled block number and supply for analysis and encoding when conditions are met.

Drosera Configuration A TOML configuration file that defines the trap path, response contract, and environment variables. This file is used to bootstrap the trap and connect it to the Drosera runtime for testing and deployment, and specifies the response_function (e.g., respondWithIncentive(uint256)) used to forward the encoded incentive amount to the partner.

Purpose

The trap enables developers to simulate, observe, and test automated incentive forwarding triggered by Lido reward events in a controlled testnet environment. It is particularly useful for:

Tracking stETH supply increases as a proxy for reward issuance
Validating how automated responders can capture and redirect a share of new rewards
Experimenting with Drosera’s trap lifecycle, cooldowns, and gas usage when creating a feedback loop

Results

When deployed with Drosera’s dryrun, the trap reports gas usage for collect and shouldRespond functions, along with information about sampled block numbers, supply deltas, and the encoded response payload (the incentive amount). These results help confirm that the trap identifies reward events correctly and that the responder can forward the intended incentive share to the partner.




Prerequisites
Ubuntu/Linux environment (WSL Ubuntu works well)
At least 4 CPU cores and 8GB RAM recommended
Basic CLI knowledge
Ethereum private key with funds on Hoodi testnet
Open ports: 31313 and 31314 (or your configured ports)

Install Dependencies
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl screen ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
Create a screen with screen -S drosera

To minimize your screen ctrl then a + d to detach it

To resume screen screen -r drosera

don't spam multiple screens to make your work easier to follow
🔹1. Drosera Trap Setup
Install Required Tools
cd #ensure you in root directory

# Drosera CLI
curl -L https://app.drosera.io/install | bash
source ~/.bashrc
droseraup

# Foundry CLI (Solidity development)
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup

# Bun (JavaScript runtime)
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
Initialize Trap Project
mkdir ~/my-drosera-trap
cd ~/my-drosera-trap

git config --global user.email "your_github_email@example.com"
git config --global user.name "your_github_username"

forge init -t drosera-network/trap-foundry-template
Replace your_github_email@example.com with your actual email used to open your github account, replace your_github_username with your github username

Build Trap
bun install
forge build