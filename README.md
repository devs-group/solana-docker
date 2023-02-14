# Solana Docker

A Multiarch Solana docker image.

## Description

* The official Solana docker-image unfortunatly does not run on the Apple A1.
The only way to do so is to build from source.

* Our image is made by cross compiling the source for different architectures.
* Currently we support **amd64** (x86)  and **arm64**. (More might be added in the future)


## Getting Started

### Installing

* You can easily get the image by running:
    ```
    docker pull ghcr.io/devs-group/solana-docker
    ```

* This of course requires you to have docker installed on your machine.


### Running

* After pulling the image you can just run it by calling:
    ```
    docker run ghcr.io/devs-group/solana-docker
    ```
    This runs the **solana-test-validator** by default. To run the **solana-validator** use:

    ```
    docker run ghcr.io/devs-group/solana-docker solana-validator
    ```

***

## Help

Any Questions? Suggestions or Issues?
- Feel free to open a github issue.

## License

This project is licensed under the Apache 2.0 License - see the LICENSE.md file for details