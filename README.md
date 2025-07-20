# Decentralized Public Disc Golf Course Management System

A comprehensive blockchain-based system for managing public disc golf courses, built on the Stacks blockchain using Clarity smart contracts.

## Overview

This system provides decentralized management for public disc golf courses through five interconnected smart contracts:

1. **Course Maintenance Contract** - Manages basket repairs and fairway clearing
2. **Tournament Organization Contract** - Schedules and manages disc golf competitions
3. **Equipment Rental Contract** - Provides disc rental services for new players
4. **Score Tracking Contract** - Maintains course records and player statistics
5. **Trail Maintenance Contract** - Coordinates path clearing and signage updates

## Features

### Course Maintenance
- Track basket conditions and repair needs
- Schedule fairway maintenance tasks
- Manage maintenance crew assignments
- Monitor equipment status

### Tournament Organization
- Create and manage tournament events
- Handle player registrations
- Track tournament results
- Manage entry fees and prizes

### Equipment Rental
- Rent disc golf discs to players
- Track rental inventory
- Manage rental fees and deposits
- Monitor equipment condition

### Score Tracking
- Record player scores for rounds
- Maintain course records
- Track player statistics
- Generate leaderboards

### Trail Maintenance
- Schedule path clearing activities
- Manage signage updates
- Coordinate volunteer efforts
- Track maintenance completion

## Contract Architecture

Each contract operates independently with its own state management:

- **Data Storage**: Uses Clarity maps for efficient data retrieval
- **Access Control**: Principal-based permissions for different user roles
- **Error Handling**: Comprehensive error codes for all operations
- **State Management**: Atomic operations with proper validation

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for deployment

### Installation

\`\`\`bash
git clone <repository-url>
cd disc-golf-course
npm install
\`\`\`

### Testing

\`\`\`bash
npm test
\`\`\`

### Deployment

\`\`\`bash
clarinet deploy
\`\`\`

## Usage Examples

### Course Maintenance
\`\`\`clarity
;; Report a basket needing repair
(contract-call? .course-maintenance report-basket-issue u1 "Chains are loose")

;; Schedule fairway clearing
(contract-call? .course-maintenance schedule-fairway-maintenance u3 u1234567890)
\`\`\`

### Tournament Organization
\`\`\`clarity
;; Create a new tournament
(contract-call? .tournament-organization create-tournament
"Spring Championship" u1234567890 u50000000)

;; Register for tournament
(contract-call? .tournament-organization register-player u1)
\`\`\`

### Equipment Rental
\`\`\`clarity
;; Rent discs
(contract-call? .equipment-rental rent-discs u3 u1000000)

;; Return discs
(contract-call? .equipment-rental return-discs u1)
\`\`\`

### Score Tracking
\`\`\`clarity
;; Submit round score
(contract-call? .score-tracking submit-score u1 u68)

;; Get course record
(contract-call? .score-tracking get-course-record)
\`\`\`

### Trail Maintenance
\`\`\`clarity
;; Schedule trail clearing
(contract-call? .trail-maintenance schedule-trail-work u2 "overgrown-vegetation")

;; Update signage
(contract-call? .trail-maintenance update-signage u5 "new-hole-info")
\`\`\`

## Error Codes

Each contract uses standardized error codes:
- u100-199: General errors
- u200-299: Permission errors
- u300-399: Validation errors
- u400-499: State errors
- u500-599: Resource errors

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details
