@echo off
reg import C:\OEM\RDPApps.reg
reg import C:\OEM\Container.reg
powershell -NoProfile -ExecutionPolicy Bypass -File C:\OEM\bootstrap.ps1
