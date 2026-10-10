# Fedora Workstation Setup

Automated post-installation and configuration script for Fedora Workstation, designed for any hardware running AMD graphics.

## What This Script Does

* Enables and updates **RPM Fusion** repositories (Free and Non-Free).
* Configures multimedia codecs and **AMD VA-API** hardware video acceleration.
* Installs containerization tools (**Podman**, **Podman-Docker** alias, **Distrobox**).
* Sets up system optimizations (`fstrim.timer` for SSDs) and automatic security updates via `dnf-automatic`.
* Installs developer dependencies and tools (Git, Curl, Wget, Nano, Htop, Neovim).
* Installs the **Rust** toolchain via Rustup.

---

## Hardware Compatibility & Customization

This script is configured out-of-the-box for **AMD graphics**. 

If you are using a different GPU manufacturer, open `setup.sh` and modify **Section 5 (GPU drivers)** before running it:
* **For AMD:** Keep the AMD lines active (default).
* **For NVIDIA or Intel:** Comment out the AMD lines in section 5 and uncomment the respective lines for **NVIDIA** or **INTEL** provided in the script.

---

## Usage

<Steps>
  <Step title="Clone the Repository">
    Open your terminal and clone your repository (or download the script directly):
    ```bash
    git clone https://github.com/Vikingu-del/Fedora-Post-Installation-for-Medion.git
    cd Fedora-Post-Installation-for-Medion
    ```
    *Verification:* Run `ls` to confirm `setup.sh` is present in the current directory.
  </Step>

  <Step title="Make the Script Executable">
    Grant execution permissions to the script file:
    ```bash
    chmod +x setup.sh
    ```
    *Verification:* Running `ls -l setup.sh` shows executable permissions (`-rwxr-xr-x`).
  </Step>

  <Step title="Run the Script">
    Execute the script with sudo/root privileges where required:
    ```bash
    ./setup.sh
    ```
    *Verification:* The script runs all installation steps sequentially and finishes with `Setup complete!`.
  </Step>
</Steps>

## Requirements

* **OS:** Fedora Workstation (tested on Fedora 44+)# Fedora Workstation Setup
