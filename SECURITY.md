# Security Policy

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.3.x   | :white_check_mark: |
| 1.2.x   | :white_check_mark: |
| 1.1.x   | :white_check_mark: |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

---

## Reporting Security Vulnerabilities

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

### Email
- Send an email to: **security@thientam.app**
- Include detailed information about the vulnerability
- Provide steps to reproduce (if applicable)

### GitHub Security Advisory
- Visit: [GitHub Security Advisories](https://github.com/trahoangdev/thien-tam-app/security/advisories)
- Click "Report a vulnerability"
- Fill out the security advisory form

---

## Disclosure Policy

1. **Initial Response**: We will acknowledge receipt of your report within 48 hours
2. **Investigation**: We will investigate and provide an update within 7 days
3. **Fix Development**: We will work on a fix and update you on progress
4. **Public Disclosure**: We will coordinate disclosure after the fix is released

### Timeline for Fixes
- **Critical**: 7 days or less
- **High**: 14 days or less
- **Medium**: 30 days or less
- **Low**: Next regular release

---

## Security Best Practices

### For Users

#### Mobile App
- Keep the app updated to the latest version
- Use strong, unique passwords
- Enable device lock screen (PIN, fingerprint, face ID)
- Be cautious with third-party app stores
- Report suspicious behavior immediately

#### Admin Panel
- Use strong passwords (minimum 12 characters)
- Enable two-factor authentication (when available)
- Don't share admin credentials
- Log out after each session
- Review admin activity logs regularly

#### Backend
- Keep dependencies updated
- Use strong JWT secrets (32+ characters)
- Enable HTTPS for production
- Configure proper CORS origins
- Regular security audits
- Monitor logs for suspicious activity

### For Developers

#### Code Security
- Never commit secrets or API keys to version control
- Use environment variables for sensitive data
- Implement input validation on all user inputs
- Use parameterized queries (MongoDB)
- Sanitize user inputs to prevent injection attacks
- Implement rate limiting on all endpoints
- Use HTTPS for all external API calls

#### Authentication & Authorization
- Implement JWT with secure configuration
- Use bcrypt for password hashing (10+ rounds)
- Implement token expiration and refresh mechanism
- Use role-based access control (RBAC)
- Validate tokens on all protected endpoints

#### Database Security
- Use MongoDB authentication
- Encrypt connections (TLS/SSL)
- Implement database backups
- Use least-privilege access principle
- Regular security updates
- Monitor for suspicious queries

#### API Security
- Implement rate limiting (15-min windows)
- Use Helmet.js for security headers
- Configure CORS properly
- Validate and sanitize all inputs
- Implement comprehensive error handling
- Use HTTPS in production
- Log security events

---

## Known Security Features

### Implemented

✅ **Authentication**
- JWT-based authentication
- Bcrypt password hashing (10 salt rounds)
- Token refresh mechanism
- Role-based access control (RBAC)

✅ **API Security**
- Rate limiting (300 req/15min globally, 10 req/15min for auth)
- Helmet.js security headers
- CORS configuration
- Input validation with Zod
- Error handling middleware

✅ **Data Protection**
- MongoDB authentication
- Secure token storage (flutter_secure_storage)
- HTTPS enforcement (production)
- Environment variable management

✅ **Mobile Security**
- Secure storage for tokens
- Network security configuration (Android)
- TLS certificate pinning (recommended)
- App signature verification

### Planned

🔜 **Two-Factor Authentication (2FA)**
- TOTP-based 2FA for admin accounts
- Backup codes
- Recovery email

🔜 **Advanced Security**
- Security event logging
- Intrusion detection
- Automated vulnerability scanning
- Penetration testing

🔜 **Privacy Features**
- GDPR compliance tools
- Data encryption at rest
- User data export/deletion
- Privacy policy integration

---

## Vulnerability Categories

### Critical (P0)
- Remote code execution (RCE)
- SQL/NoSQL injection
- Authentication bypass
- Privilege escalation
- Sensitive data exposure

### High (P1)
- Cross-site scripting (XSS)
- Cross-site request forgery (CSRF)
- Insecure direct object reference (IDOR)
- Broken access control
- Insufficient logging/monitoring

### Medium (P2)
- Security misconfiguration
- Insecure deserialization
- Missing function-level access control
- Unvalidated redirects
- Weak cryptography

### Low (P3)
- Information disclosure
- Insufficient session management
- Weak password policies
- Missing security headers
- Outdated dependencies

---

## Security Checklist for Deployment

### Backend
- [ ] Use strong JWT secrets (32+ characters)
- [ ] Enable MongoDB authentication
- [ ] Configure HTTPS/SSL certificates
- [ ] Set up proper CORS origins
- [ ] Enable rate limiting
- [ ] Configure Helmet.js security headers
- [ ] Use environment variables for secrets
- [ ] Enable request logging
- [ ] Set up error monitoring
- [ ] Configure firewall rules

### Frontend
- [ ] Use secure token storage
- [ ] Implement SSL pinning
- [ ] Configure network security config
- [ ] Enable certificate validation
- [ ] Implement secure backup/restore
- [ ] Add biometric authentication
- [ ] Implement app integrity checks

### Infrastructure
- [ ] Regular security updates
- [ ] Automated backups
- [ ] Disaster recovery plan
- [ ] Intrusion detection system
- [ ] DDoS protection
- [ ] WAF (Web Application Firewall)
- [ ] Network segmentation
- [ ] Access control lists
- [ ] Security monitoring
- [ ] Incident response plan

---

## Security Updates

We regularly update dependencies and apply security patches. Check the [CHANGELOG.md](CHANGELOG.md) for security-related updates.

### How to Check for Updates

```bash
# Backend
cd backend_thien_tam_app
npm audit
npm update

# Frontend
cd thien_tam_app
flutter pub outdated
flutter pub upgrade
```

---

## Incident Response

### If a Security Breach Occurs

1. **Immediate Actions**
   - Identify the scope of the breach
   - Contain the vulnerability
   - Notify affected users
   - Document the incident

2. **Short-term Actions**
   - Fix the vulnerability
   - Deploy security patch
   - Monitor for further issues
   - Update security policies

3. **Long-term Actions**
   - Post-mortem analysis
   - Improve security measures
   - User communication
   - Update documentation

---

## Compliance

### Current Compliance
- OWASP Top 10 mitigated
- GDPR preparation
- General security best practices

### Planned Compliance
- ISO 27001
- SOC 2
- HIPAA (if applicable)
- Regional privacy regulations

---

## Security Resources

### Official Documentation
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [MongoDB Security](https://docs.mongodb.com/manual/security/)
- [Flutter Security](https://docs.flutter.dev/security)
- [Node.js Security](https://nodejs.org/en/docs/guides/security/)

### Tools
- [npm audit](https://docs.npmjs.com/cli/v8/commands/npm-audit)
- [dart pub outdated](https://dart.dev/tools/pub/cmd/pub-outdated)
- [OWASP ZAP](https://www.zaproxy.org/)
- [SonarQube](https://www.sonarqube.org/)

---

## Acknowledgments

We thank security researchers who responsibly disclosed vulnerabilities to help improve the security of Thiền Tâm App.

---

## Contact

- **Security Email**: security@thientam.app
- **GitHub**: [Security Advisories](https://github.com/trahoangdev/thien-tam-app/security/advisories)
- **Website**: [thientam.app](https://thientam.app)

---

**Last Updated**: October 28, 2025  
**Version**: 1.3.1

