#!/bin/bash

# ROCm 7.2.0 Installation Script for Zorin OS 18
# This script automates the installation of ROCm on Zorin OS and other Ubuntu-based distributions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ROCM_VERSION="7.2.0"
INSTALLER_VERSION="1.2.5.70200-25-43~24.04"
INSTALLER_URL="https://repo.radeon.com/rocm/installer/rocm-runfile-installer/rocm-rel-7.2/ubuntu/24.04/rocm-installer_${INSTALLER_VERSION}.run"
INSTALL_DIR="$HOME/rocm-installer/rocm-${ROCM_VERSION}"

# Functions
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    print_status "Checking requirements..."
    
    # Check if running on Zorin OS or Ubuntu-based system
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot determine OS version. /etc/os-release not found."
        exit 1
    fi
    
    # Check for sudo access
    if ! sudo -n true 2>/dev/null; then
        print_status "Requesting sudo access..."
        sudo true
    fi
    
    # Check disk space (need at least 30GB)
    available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $available_space -lt 30 ]]; then
        print_error "Insufficient disk space. Need at least 30GB, available: ${available_space}GB"
        exit 1
    fi
    
    print_status "Requirements check passed."
}

backup_os_release() {
    print_status "Backing up OS configuration..."
    if [[ -f /etc/os-release.backup ]]; then
        print_warning "Backup file already exists. Restoring original first..."
        restore_os_release
    fi
    
    sudo cp /etc/os-release /etc/os-release.backup
    print_status "OS configuration backed up."
}

modify_os_detection() {
    print_status "Modifying OS detection for installer..."
    
    # Create temporary modified os-release
    sudo sed 's/^ID=zorin/ID=ubuntu/' /etc/os-release.backup | \
    sudo sed 's/^VERSION_ID="18"/VERSION_ID="24.04"/' | \
    sudo tee /etc/os-release > /dev/null
    
    print_status "OS detection modified."
}

restore_os_release() {
    if [[ -f /etc/os-release.backup ]]; then
        print_status "Restoring original OS configuration..."
        sudo mv /etc/os-release.backup /etc/os-release
        print_status "OS configuration restored."
    fi
}

download_installer() {
    print_status "Downloading ROCm installer..."
    
    if [[ -f "rocm-installer_${INSTALLER_VERSION}.run" ]]; then
        print_warning "Installer already exists. Skipping download."
    else
        wget "$INSTALLER_URL" -O "rocm-installer_${INSTALLER_VERSION}.run"
        print_status "Download completed."
    fi
}

install_rocm() {
    print_status "Starting ROCm installation..."
    print_warning "This may take 30+ minutes and requires ~30GB of space."
    
    # Make installer executable
    chmod +x "rocm-installer_${INSTALLER_VERSION}.run"
    
    # Run installer
    bash "rocm-installer_${INSTALLER_VERSION}.run" deps=install force rocm
    
    print_status "ROCm installation completed."
}

configure_environment() {
    print_status "Configuring shell environment..."
    
    # Check if already configured
    if grep -q "rocm-installer/rocm-${ROCM_VERSION}/bin" ~/.bashrc; then
        print_warning "Environment already configured."
        return
    fi
    
    # Add to bashrc
    echo "" >> ~/.bashrc
    echo "# ROCm ${ROCM_VERSION} Environment" >> ~/.bashrc
    echo "export PATH=\$HOME/rocm-installer/rocm-${ROCM_VERSION}/bin:\$PATH" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=\$HOME/rocm-installer/rocm-${ROCM_VERSION}/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc
    
    # Source the configuration
    source ~/.bashrc
    
    print_status "Environment configured."
}

verify_installation() {
    print_status "Verifying installation..."
    
    # Check if installation directory exists
    if [[ ! -d "$INSTALL_DIR" ]]; then
        print_error "Installation directory not found: $INSTALL_DIR"
        return 1
    fi
    
    # Check if key binaries exist
    local binaries=("rocminfo" "hipcc" "rocm-smi")
    for binary in "${binaries[@]}"; do
        if [[ ! -f "$INSTALL_DIR/bin/$binary" ]]; then
            print_error "Binary not found: $binary"
            return 1
        fi
    done
    
    # Test rocminfo
    if "$INSTALL_DIR/bin/rocminfo" > /dev/null 2>&1; then
        print_status "rocminfo test passed."
    else
        print_warning "rocminfo test failed - GPU may not be detected."
    fi
    
    # Test hipcc
    if "$INSTALL_DIR/bin/hipcc" --version > /dev/null 2>&1; then
        print_status "hipcc test passed."
    else
        print_warning "hipcc test failed."
    fi
    
    print_status "Installation verification completed."
}

cleanup() {
    print_status "Cleaning up..."
    # Optionally remove installer
    read -p "Remove installer file? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "rocm-installer_${INSTALLER_VERSION}.run"
        print_status "Installer removed."
    fi
}

show_post_install_info() {
    print_status "Installation completed successfully!"
    echo
    echo "=== Post-Installation Information ==="
    echo "ROCm Installation Directory: $INSTALL_DIR"
    echo "Total Size: $(du -sh "$INSTALL_DIR" | cut -f1)"
    echo
    echo "To use ROCm, either:"
    echo "1. Restart your terminal, or"
    echo "2. Run: source ~/.bashrc"
    echo
    echo "Test commands:"
    echo "  rocminfo          # Show GPU information"
    echo "  hipcc --version    # Show HIP compiler version"
    echo "  rocm-smi           # Show GPU status"
    echo
    echo "Example compilation:"
    echo "  hipcc your_file.cpp -o your_program"
    echo
}

# Main execution
main() {
    echo "=== ROCm ${ROCM_VERSION} Installation Script for Zorin OS ==="
    echo
    
    # Trap to restore OS configuration on exit
    trap restore_os_release EXIT
    
    check_requirements
    backup_os_release
    modify_os_detection
    download_installer
    install_rocm
    configure_environment
    verify_installation
    cleanup
    show_post_install_info
    
    # Restore OS configuration before exit
    restore_os_release
    
    print_status "Installation script completed successfully!"
}

# Run main function
main "$@"
