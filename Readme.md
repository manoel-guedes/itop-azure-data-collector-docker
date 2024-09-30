# iTop Azure Data Collector Docker

This project provides a Docker container for collecting data from Azure and sending it to iTop.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

## Introduction

The iTop Azure Data Collector Docker project is designed to streamline the process of collecting data from Azure and integrating it with iTop. This containerized solution ensures a consistent and reliable data collection process.
It is based on the Combodo Azure Data Collector, avaiable at the iTop Hub website (and Combodo´s Github).
It can be run as a Container Instance on Azure (remember to set to the restart-policy to Never)
    az container create --resource-group myResourceGroup --name myContainerInstance --image itop-azure-data-collector --restart-policy Never
Azure Logic App can be used to schedule runs

## Features

- Easy setup and deployment using Docker
- Automated data collection from Azure
- Seamless integration with iTop
- Configurable parameters for customization

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Docker installed on your machine
- Azure account with necessary permissions
- iTop instance set up and running

## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/itop-azure-data-collector-docker.git
    cd itop-azure-data-collector-docker
    ```

2. Build the Docker image:
    ```sh
    docker build -t itop-azure-data-collector .
    ```

## Usage

1. Run the Docker container:
    ```sh
    docker run -d --name itop-azure-data-collector itop-azure-data-collector
    ```

2. Check the logs to ensure the data collector is running:
    ```sh
    docker logs itop-azure-data-collector
    ```

## Configuration

Configure the data collector by editing the `params.local.xml` and create an `.env` file based on the `.env.example`. 
Ensure you provide the necessary Azure credentials and iTop endpoint details.

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License

This project is licensed under the GPL License.
