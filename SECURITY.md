# Security Policy

The Docker image and code quality are regularly checked for vulnerabilities and CVEs by Snyk and CodeQL.

## Supported Versions

The following versions are currently being supported with security updates:

| Version | Supported          | Rsync version          | Alpine version          | Support Until  |
| ------- | ------------------ | ------------------ | ------------------ | ------------------ | 
| (``v8``) 8.0.2  | :white_check_mark: | >= 3.4.1-r1 | 3.23.0 | LTS (2026-*) |
| 8.0.1  | :white_check_mark: | >= 3.4.1-r1 | 3.23.0 | Feb, 1st 2026 |
| 8.0.0  | :x: EOL (due to regression #90) | >= 3.4.1-r1 | 3.23.0 | † Dec, 6th 2025 |
| 7.1.0  | :white_check_mark: | >= 3.4.1-r0 | 3.22.1 | Apr, 1st 2026 |
| 7.0.2   | :warning: DEPRECATED | >= 3.4.0-r0 | 3.22.1 | Feb, 1st 2026 |
| 7.0.1   | :x: EOL | < 3.4.0 | 3.22.1 | † Dec, 6th 2025 |
| 7.0.0   | :x: EOL | < 3.4.0| 3.19.1 | † Dec, 6th 2025 |
| 6.x   | :x: EOL |< 3.4.0| 3.17.2 | † 2024 |
| 5.x   | :x: EOL |< 3.4.0| 3.11 - 3.14.1 - 3.15 - 3.16 - 3.17.2 | † 2024 |
| 4.x   | :x: EOL |< 3.4.0| 3.11 |  † |
| 3.0   | :x: EOL |< 3.4.0| N/A | † |
| 2.0   | :x: EOL               |< 3.4.0| Ubuntu | † |
| 1.0   | :x: EOL               |< 3.4.0| Ubuntu | † |

### Terminology

EOL = End of life (no support/no updates)

DEPRECATED = Close to EOL (support/no updates)

## Reporting a Vulnerability

You can report a vulnerability by creating an issue.
