# Payload Pipeline

This is a first attempt at automating payload generation with a C2 for testing AV/EDR security controls. I have expanded it into other containers and CI/CD flows so this is now public, can't promise that any of it works but the intent is to containerize all payload evasion/obfuscation techniques for easy grab and run.

## Prerequisites

- Docker
- Docker Compose
- Shellcode files (https_x64.bin, https_x86.bin, https.64.exe)

## Quick Start

### 1. Clone/Download This Repository
```bash
git clone <your-repo> payload-pipeline
cd payload-pipeline
```

### 2. Add Your Shellcode

Place your shellcode files in the `shellcode/` directory:
```bash
shellcode/
├── https_x64.bin
├── https_x86.bin
└── https.64.exe
```

### 3. Run the Pipeline
```bash
chmod +x run-pipeline.sh
./run-pipeline.sh
```

The script will:
- Pull all required Docker images from GHCR
- Process all shellcode files through each tool
- Generate multiple payload variants
- Create ISO and ZIP packages
- Generate hash reports (MD5, SHA1, SHA256)

### 4. Collect Your Payloads

All generated payloads will be in the `output/` directory:
- `*-bankai-*.exe` - Bankai payloads
- `*-freeze-*.exe` - Freeze.rs payloads
- `*-uru-*.exe` - Uru payloads
- `*-shhhloader-*.exe` - Shhhloader payloads
- `*-scarecrow-*.exe` - ScareCrow payloads
- `*-nim-*.exe` - Nimalathatep EXE payloads
- `*-nim-*.cpl` - Nimalathatep CPL payloads
- `*-mangled-*.exe` - Mangled (inflated) payloads
- `*.iso` - ISO containers
- `*.zip` - ZIP containers

Hash reports will be in the `hashes/` directory.

## Manual Operations

### Pull Images Only
```bash
docker-compose pull
```

### Run Specific Tool
```bash
# Example: Run only Bankai
docker-compose run --rm bankai

# Example: Run only hash generator
docker-compose run --rm hash-generator
```

### Clean Up
```bash
# Remove containers
docker-compose down

# Remove generated files
rm -rf output/* hashes/* logs/*
```

## Customization

### Modify Tool Parameters

Edit `docker-compose.yml` to change tool-specific parameters:

- **Bankai**: Change template or architecture
- **Freeze.rs**: Change encryption method or process
- **Uru**: Change configuration file
- **Shhhloader**: Change injection method or process
- **ScareCrow**: Change domain or loader type
- **Mangle**: Change inflation size (default: 50MB)

### Add Additional Shellcode

Simply drop more `.bin` or `.exe` files into the `shellcode/` directory before running.

## Troubleshooting

### Images Won't Pull

Ensure you're authenticated with GHCR:
```bash
echo $PAT | docker login ghcr.io -u nn0ses --password-stdin
```

### Pipeline Fails

Check logs for specific container:
```bash
docker-compose logs <service-name>
```

### Permission Issues

Ensure shellcode directory is readable:
```bash
chmod -R 755 shellcode/
```

## Support

For issues or questions, contact the tool maintainer.
```

## Directory Structure
```
payload-pipeline/
├── docker-compose.yml
├── run-pipeline.sh
├── README.md
├── shellcode/
│   ├── https_x64.bin
│   ├── https_x86.bin
│   └── https.64.exe
├── output/          (generated)
├── hashes/          (generated)
└── logs/            (generated)
