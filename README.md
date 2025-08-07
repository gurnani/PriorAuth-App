# ABC HealthCare Prior Authorization System

A hybrid Classic ASP/VBScript and TypeScript application for managing prior authorization workflows in healthcare.

## Features

- **User Authentication**: Secure login system
- **Prior Authorization Management**: Create, edit, view, and search authorization requests
- **Lookup Functionality**: Modal-based lookups for patients, physicians, sites, and diagnosis codes
- **Responsive Design**: Light blue color scheme with ABC HealthCare branding
- **IIS Compatible**: Designed to run on Internet Information Services

## Technology Stack

- **Backend**: Classic ASP with VBScript
- **Frontend**: HTML5, CSS3, JavaScript/TypeScript
- **Server**: Microsoft IIS
- **Database**: SQL Server (connection strings to be configured)
- **Build Tools**: TypeScript Compiler, npm

## File Structure

```
prior_auth_app/
├── src/                        # TypeScript source files
│   ├── types/
│   │   └── interfaces.ts       # TypeScript interfaces and types
│   ├── lookups/
│   │   ├── patient-lookup.ts   # Patient lookup TypeScript
│   │   ├── physician-lookup.ts # Physician lookup TypeScript
│   │   └── site-lookup.ts      # Site lookup TypeScript
│   ├── form.ts                 # Main form TypeScript
│   └── search.ts               # Search functionality TypeScript
├── js/                         # Compiled JavaScript files
│   ├── form.js                 # Main form functionality
│   ├── search.js               # Search page functionality
│   ├── patient_lookup.js       # Patient lookup with API calls
│   ├── site_lookup.js          # Site lookup with API calls
│   └── physician_lookup.js     # Physician lookup with API calls
├── css/
│   └── styles.css              # Main stylesheet with light blue theme
├── images/
│   └── abc_healthcare_logo.svg # Company logo (SVG format)
├── lookups/
│   ├── diagnosis_lookup.asp    # Diagnosis code lookup modal
│   ├── patient_lookup.asp      # Patient lookup modal
│   ├── site_lookup.asp         # Site lookup modal
│   └── physician_lookup.asp    # Physician lookup modal
├── default.asp                 # Login page
├── home.asp                    # Main dashboard
├── search.asp                  # Search requests page
├── add_new.asp                 # Add new request form
├── edit_view.asp               # Edit/view existing request
├── save_request.asp            # Form submission handler
├── logout.asp                  # Logout handler
├── web.config                  # IIS configuration
├── tsconfig.json               # TypeScript configuration
├── package.json                # npm package configuration
└── README.md                   # This file
```

## Installation

1. **Prerequisites**:
   - Node.js and npm (for TypeScript compilation)
   - Microsoft IIS with Classic ASP enabled
   - SQL Server (for database)

2. **Build Setup**:
   ```bash
   npm install
   npm run build
   ```

3. **IIS Setup**:
   - Copy all files to your IIS web directory
   - Ensure Classic ASP is enabled in IIS
   - Configure application pool to use Classic .NET Framework

4. **Database Configuration**:
   - Update connection strings in ASP files
   - Create necessary database tables for:
     - Users
     - Prior authorization requests
     - Patients
     - Physicians
     - Sites
     - Diagnosis codes

5. **Permissions**:
   - Ensure IIS_IUSRS has read/execute permissions on the application folder
   - Configure session state if using SQL Server session management

## Usage

1. **Login**: Access the application through `default.asp`
2. **Navigation**: Use the home page to access main functions
3. **Create Requests**: Click "Add New Request" to create prior authorization requests
4. **Search**: Use "Edit / View" to search and modify existing requests
5. **Lookups**: Use lookup buttons in forms to search for patients, physicians, sites, and diagnosis codes

## Lookup Functionality

### Patient Lookup
- Search by name, ID, or date of birth
- API-driven results with TypeScript async/await
- Two-step selection process with detailed view

### Site Lookup
- Search by name, ID, or city
- Displays site details before selection
- Populate button to confirm selection

### Physician Lookup
- Search by name, ID, or NPI number
- Direct selection from search results

### Diagnosis Lookup
- Dropdown-based selection
- Database-driven code categories
- Automatic description population

## Customization

### Branding
- Update logo in `/images/abc_healthcare_logo.png`
- Modify company name in all ASP files
- Adjust colors in `/css/styles.css` using CSS custom properties

### Database Integration
- Update connection strings in ASP files
- Modify SQL queries in lookup pages
- Implement proper error handling and logging

### API Integration
- Update API endpoints in JavaScript files
- Implement authentication for API calls
- Add error handling for network requests

## Security Considerations

- Implement proper input validation
- Use parameterized queries to prevent SQL injection
- Enable HTTPS in production
- Configure proper session management
- Implement role-based access control

## Browser Compatibility

- Internet Explorer 11+
- Microsoft Edge
- Chrome 60+
- Firefox 55+
- Safari 11+

## Support

For technical support or questions about this application, please contact the development team.

## License

© 2025 ABC HealthCare. All rights reserved.
