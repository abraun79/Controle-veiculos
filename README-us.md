<img height="20px"  src="https://i.imgur.com/1ubgfmC.png"><a href="README.md">  Leia em português!</a><br/>
<img height="20px"  src="https://i.imgur.com/UrpOBOr.png"><a href="README-us.md">  Read in English!</a>

# Vehicle Control System

This project is a vehicle control system developed in PHP and MySQL, configured and installed automatically through a Shell Script. The script handles all the necessary installations, including Apache, PHP, MySQL, and additional libraries such as FPDF.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Database Configuration](#database-configuration)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

Before running the installation script, make sure you meet the following requirements:

- **Operating System**: Linux (tested on Ubuntu 20.04 and higher)
- **User with sudo privileges**
- **Internet connection** (for package installation)
- **Bash shell** (you can check by running `bash --version`)

## Installation

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/abraun79/Controle-veiculos.git
    ```

2. Navigate to the project directory:

    ```bash
    cd Controle-veiculos
    ```

3. Grant execution permission to the installation script:

    ```bash
    chmod +x install.sh
    ```

4. Run the installation script:

    ```bash
    sudo ./install.sh
    ```

The script will perform the following tasks:

- Update system packages
- Install Apache, PHP, MySQL, and other dependencies
- Configure MySQL, including the creation of the database and required tables
- Install the FPDF library using Composer
- Configure permissions and the Apache server

## Usage

After installation, the system will be available at `http://localhost/` or at the server IP where the application is installed. You can access the web interface to manage vehicles, drivers, and entry/exit records.

### Execution Example

```bash
sudo ./install.sh
```
The script will automatically configure the environment and start the Apache server. If everything works correctly, you will see the message "Installation and configuration completed successfully."

### Project Structure
```
├── install.sh            # Main installation script
├── README.md             # Project documentation
├── config/               # Additional configuration files
├── scripts/              # Auxiliary scripts
├── /var/www/html/veiculos # Main application directory
└── composer.json         # Composer configuration file
```
-`install.sh:` Main script that performs the installation and configuration.
-`/var/www/html/veiculos:` Directory where the web application will be installed.
-`composer.json:` File that defines the PHP dependencies, such as FPDF.

### Database Configuration

The installation script automatically creates the database and necessary tables. The default credentials are:

- `Database:` controle_veiculos
- `User:` teste (User of your choice)
- `Password:` test@12345 (Password of your choice)

The database contains the following tables:

- `veiculos:` Stores vehicle information.
- `motoristas:` Stores driver information.
- `entradas_saidas:` Records vehicle entries and exits.

### Contributing

Pull requests are welcome. For major changes or bugs, please open an issue for discussion.
For direct contact, send me an email: albraun79@outlook.com

### License

This project is licensed under the MIT License. See the LICENSE file for more details.
```
MIT License

Copyright (c) 2024 Alessandro Braun

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
