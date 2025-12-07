# Security Policy

The Docker image and code quality are regularly checked for vulnerabilities and CVEs by Snyk and CodeQL.

## Supported Versions

The following versions are currently being supported with security updates:

| Version | Supported          | Rsync version          | Alpine version          |
| ------- | ------------------ | ------------------ | ------------------ |
| 8.0.2  | :white_check_mark: | >= 3.4.1-r1 | 3.23.0 |
| 8.0.1  | :white_check_mark: | >= 3.4.1-r1 | 3.23.0 |
| 8.0.0  | :x: EOL (due to regression #90) | >= 3.4.1-r1 | 3.23.0 |
| 7.1.0  | :white_check_mark: | >= 3.4.1-r0 | 3.22.1 |
| 7.0.2   | :warning: DEPRECATED | >= 3.4.0-r0 | 3.22.1 |
| 7.0.1   | :x: EOL | < 3.4.0 | 3.22.1 |
| 7.0.0   | :x: EOL | < 3.4.0| 3.19.1 |
| 6.x   | :x: EOL |< 3.4.0| 3.17.2 |
| 5.x   | :x: EOL |< 3.4.0| 3.11 - 3.14.1 - 3.15 - 3.16 - 3.17.2 |
| 4.x   | :x: EOL |< 3.4.0| 3.11 |
| 3.0   | :x: EOL |< 3.4.0| N/A |
| 2.0   | :x: EOL               |< 3.4.0| Ubuntu |
| 1.0   | :x: EOL               |< 3.4.0| Ubuntu |

### Terminology

EOL = End of life (no support/no updates)

DEPRECATED = Close to EOL (support/no updates)

## Reporting a Vulnerability

You can report a vulnerability by creating an issue.
