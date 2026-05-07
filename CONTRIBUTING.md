# Contributing to Kasm Workspaces for Pterodactyl

First off, thank you for considering contributing to this project!

## How can I contribute?

### Reporting Bugs

- Ensure the bug was not already reported by searching on GitHub under Issues.
- If you're unable to find an open issue addressing the problem, open a new one.
- Be sure to include a title and clear description, as much relevant information as possible, and a code sample or an executable test case demonstrating the expected behavior that is not occurring.

### Suggesting Enhancements

- Open a new issue with a clear title and description of the enhancement.
- Provide examples of how the enhancement would be used.

### Pull Requests

1. Fork the repository and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. Ensure the test suite passes.
4. Update the documentation accordingly.
5. Create a pull request!

## Development Setup

1. Fork and clone the repository.
2. Test Docker builds locally using `docker build -t kasm-test -f docker/Dockerfile .`
3. Test changes to `docker/entrypoint.sh` locally. **Note**: Kasm utilizes LinuxServer.io `s6-overlay` as its initialization daemon structure, so all custom scripts load inside `/custom-services.d/`.
