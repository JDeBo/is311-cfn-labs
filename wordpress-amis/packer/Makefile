# Makefile for WordPress Packer builds

.PHONY: all aws vagrant validate clean init

# Default target
all: validate
	packer build .

# Initialize Packer plugins
init:
	packer init .

# Validate all configurations
validate: init
	packer validate .

# Build only AWS AMIs
aws: validate
	packer build -only="*amazon-ebs.*" .

# Build only Vagrant boxes
vagrant: validate
	packer build -only="*vagrant.*" .

# Clean up build artifacts and temporary files
clean:
	rm -rf output-*
	rm -rf manifest.json
	rm -rf packer_cache

# Help target
help:
	@echo "Available targets:"
	@echo "  all      - Build all images (default)"
	@echo "  aws      - Build only AWS AMIs"
	@echo "  vagrant  - Build only Vagrant boxes"
	@echo "  init     - Initialize Packer plugins"
	@echo "  validate - Validate Packer configurations"
	@echo "  clean    - Remove build artifacts and cache"
	@echo "  help     - Show this help message"

# Example usage:
# make aws        # Build only AWS AMIs
# make vagrant    # Build only Vagrant boxes
# make clean      # Clean up build artifacts
