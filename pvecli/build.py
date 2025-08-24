#!/usr/bin/env python3

"""
Build script for creating standalone pvecli binary using PyInstaller.
"""

import os
import subprocess
import sys
from pathlib import Path


def build_binary():
    """Build standalone binary using PyInstaller."""
    
    # Ensure we're in the right directory
    project_root = Path(__file__).parent
    os.chdir(project_root)
    
    # PyInstaller command
    cmd = [
        "pyinstaller",
        "--onefile",
        "--name", "pve",
        "--console",
        "--clean",
        "pvecli/cli.py",
    ]
    
    print("Building binary with PyInstaller...")
    print(f"Command: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print("Build successful!")
        print(f"Binary created at: {project_root}/dist/pve")
        
        # Show binary info
        binary_path = project_root / "dist" / "pve"
        if binary_path.exists():
            size_mb = binary_path.stat().st_size / (1024 * 1024)
            print(f"Binary size: {size_mb:.1f} MB")
            
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"Build failed: {e}")
        print(f"stdout: {e.stdout}")
        print(f"stderr: {e.stderr}")
        return False


def install_pyinstaller():
    """Install PyInstaller if not available."""
    try:
        subprocess.run(["pyinstaller", "--version"], check=True, capture_output=True)
        print("PyInstaller is already installed")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Installing PyInstaller...")
        try:
            # Use uv instead of pip
            subprocess.run(["uv", "pip", "install", "pyinstaller"], check=True)
            return True
        except subprocess.CalledProcessError:
            print("Failed to install PyInstaller")
            return False


def main():
    """Main build function."""
    print("=== PVE CLI Binary Builder ===")
    
    if not install_pyinstaller():
        sys.exit(1)
        
    if not build_binary():
        sys.exit(1)
        
    print("\n✅ Build complete!")
    print("\nTo test the binary:")
    print("  ./dist/pve --help")
    print("  ./dist/pve vms")


if __name__ == "__main__":
    main()
