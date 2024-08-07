#!/bin/bash

wget https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-fedora-40-$(uname -m).rpm && sudo dnf install ./sunshine-fedora-40-$(uname -m).rpm && sudo systemctl start sunshine && sudo systemctl enable sunshine
