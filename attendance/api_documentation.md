# AttendNova API Documentation

## 📊 Complete API Overview

| # | Endpoint | Method | Purpose | Priority | Used In |
|---|----------|--------|---------|----------|---------|
| **Authentication** |
| 1 | `/api/auth/login` | POST | User login | **HIGH** | Login Screen |
| 2 | `/api/auth/logout` | POST | User logout | **HIGH** | Home, Profile Screen |
| 3 | `/api/auth/refresh` | POST | Refresh expired token | **HIGH** | Auto (interceptor) |
| 4 | `/api/auth/verify` | GET | Check if token is valid | **HIGH** | App Startup |
| **User Profile** |
| 5 | `/api/users/me` | GET | Get current user details | **HIGH** | Home, Profile Screen |
| 6 | `/api/users/me` | PUT | Update profile info | MEDIUM | Profile Edit |
| 7 | `/api/users/me/password` | POST | Change password | MEDIUM | Profile Screen |
| 8 | `/api/users/manager` | GET | Get manager details | MEDIUM | My Manager Screen |
| **Attendance** |
| 9 | `/api/attendance/checkin` | POST | Mark check-in | **HIGH** | Attendance Card |
| 10 | `/api/attendance/checkout` | POST | Mark check-out | **HIGH** | Attendance Card |
| 11 | `/api/attendance/today` | GET | Get today's attendance status | **HIGH** | Attendance Card |
| 12 | `/api/attendance/history` | GET | Get attendance history | **HIGH** | History Screen |
| 13 | `/api/attendance/statistics` | GET | Get attendance stats | **HIGH** | Dashboard Stats |
| 14 | `/api/attendance/monthly-chart` | GET | Get monthly data for chart | MEDIUM | Monthly Chart |
| 15 | `/api/attendance/calendar` | GET | Get calendar view data | MEDIUM | Calendar Screen |
| **Leave Management** |
| 16 | `/api/leaves` | POST | Apply for leave | **HIGH** | Leave Screen |
| 17 | `/api/leaves` | GET | Get leave history | **HIGH** | Leave Screen |
| 18 | `/api/leaves/balances` | GET | Get leave balances | **HIGH** | Leave Screen |
| 19 | `/api/leaves/:leaveId` | DELETE | Cancel leave | LOW | Leave History |
| **Notifications** |
| 20 | `/api/notifications` | GET | Get all notifications | **HIGH** | Notifications Screen |
| 21 | `/api/notifications/:id/read` | PUT | Mark one as read | MEDIUM | Notification Tap |
| 22 | `/api/notifications/read-all` | PUT | Mark all as read | LOW | Mark All Button |
| 23 | `/api/notifications/unread-count` | GET | Get unread count | MEDIUM | Header Badge |
| **Announcements** |
| 24 | `/api/announcements` | GET | Get announcements | MEDIUM | My Manager Screen |

**Total: 24 APIs**

---

## 📖 API Details (Simple Explanations)

### 🔐 1. Authentication APIs

#### 1.1 Login
**`POST /api/auth/login`**

**What it does:** Logs in a user with email and password.

**Send:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**You get:**
```json
{
  "success": true,
  "data": {
    "token": "jwt_token_here",
    "refreshToken": "refresh_token_here",
    "expiresIn": 3600,
    "user": {
      "id": "EMP001",
      "name": "Sarah Field",
      "email": "user@example.com",
      "role": "EMPLOYEE"
    }
  }
}
```

---

#### 1.2 Logout
**`POST /api/auth/logout`**

**What it does:** Logs out the current user and invalidates tokens.

**Headers:** `Authorization: Bearer {token}`

**Send:**
```json
{
  "refreshToken": "refresh_token_here"
}
```

**You get:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

#### 1.3 Refresh Token
**`POST /api/auth/refresh`**

**What it does:** Gets a new access token when the old one expires.

**Send:**
```json
{
  "refreshToken": "refresh_token_here"
}
```

**You get:**
```json
{
  "success": true,
  "data": {
    "token": "new_access_token",
    "refreshToken": "new_refresh_token",
    "expiresIn": 3600
  }
}
```

---

#### 1.4 Verify Token
**`GET /api/auth/verify`**

**What it does:** Checks if the current token is still valid.

**Headers:** `Authorization: Bearer {token}`

**You get:**
```json
{
  "success": true,
  "data": {
    "valid": true,
    "userId": "EMP001"
  }
}
```

---

### 👤 2. User Profile APIs

#### 2.1 Get Current User
**`GET /api/users/me`**

**What it does:** Gets the logged-in user's profile information.

**Headers:** `Authorization: Bearer {token}`

**You get:**
```json
{
  "success": true,
  "data": {
    "id": "EMP001",
    "name": "Sarah Field",
    "email": "user@example.com",
    "phone": "+919876543210",
    "designation": "Field Executive",
    "department": "Operations",
    "avatarUrl": "https://storage.example.com/avatar.jpg"
  }
}
```

---

#### 2.2 Update Profile
**`PUT /api/users/me`**

**What it does:** Updates user profile information.

**Headers:** `Authorization: Bearer {token}`

**Send:**
```json
{
  "name": "Sarah Field",
  "phone": "+919876543210",
  "avatarUrl": "https://storage.example.com/new_avatar.jpg"
}
```

**You get:**
```json
{
  "success": true,
  "data": {
    "id": "EMP001",
    "name": "Sarah Field",
    "phone": "+919876543210",
    "updatedAt": "2024-12-10T16:45:00Z"
  }
}
```

---

#### 2.3 Change Password
**`POST /api/users/me/password`**

**What it does:** Changes the user's password.

**Headers:** `Authorization: Bearer {token}`

**Send:**
```json
{
  "currentPassword": "oldPassword123",
  "newPassword": "newPassword456"
}
```

**You get:**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

#### 2.4 Get Manager
**`GET /api/users/manager`**

**What it does:** Gets details of the user's manager.

**Headers:** `Authorization: Bearer {token}`

**You get:**
```json
{
  "success": true,
  "data": {
    "id": "MGR001",
    "name": "John Manager",
    "email": "john@example.com",
    "phone": "+919876543211",
    "designation": "Senior Field Lead",
    "avatarUrl": "https://storage.example.com/manager.jpg"
  }
}
```

---

### 📅 3. Attendance APIs

#### 3.1 Check In
**`POST /api/attendance/checkin`**

**What it does:** Marks user as checked in for the day with location.

**Headers:** `Authorization: Bearer {token}`

**Send:**
```json
{
  "location": "123 Tech Park, Pune",
  "latitude": 18.5204,
  "longitude": 73.8567,
  "timestamp": "2024-12-10T09:15:30Z"
}
```

**You get:**
```json
{
  "success": true,
  "data": {
    "id": "ATT_20241210_001",
    "userId": "EMP001",
    "date": "2024-12-10",
    "checkIn": "2024-12-10T09:15:30Z",
    "location": "123 Tech Park, Pune"
  }
}
```

---

#### 3.2 Check Out
**`POST /api/attendance/checkout`**

**What it does:** Marks user as checked out with location and calculates hours worked.

**Headers:** `Authorization: Bearer {token}`

**Send:**
```json
{
  "attendanceId": "ATT_20241210_001",
  "location": "123 Tech Park, Pune",
  "latitude": 18.5204,
  "longitude": 73.8567,
  "timestamp": "2024-12-10T18:30:45Z"
}
```

**You get:**
```json
{
  "success": true,
  "data": {
    "id": "ATT_20241210_001",
    "checkOut": "2024-12-10T18:30:45Z",
    "hoursWorked": 9.25
  }
}
```

---

#### 3.3 Get Today's Attendance
**`GET /api/attendance/today`**

**What it does:** Checks if user has already checked in today.

**Headers:** `Authorization: Bearer {token}`

**You get (if checked in):**
```json
{
  "success": true,
  "data": {
    "id": "ATT_20241210_001",
    "checkIn": "2024-12-10T09:15:30Z",
    "checkOut": null,
    "location": "123 Tech Park, Pune"
  }
}
```

**You get (if not checked in):**
```json
{
  "success": true,
  "data": null
}
```

---

#### 3.4 Get Attendance History
**`GET /api/attendance/history?startDate=2024-11-01&endDate=2024-11-30&page=1&limit=30`**

**What it does:** Gets past attendance records with optional date filtering.

**Headers:** `Authorization: Bearer {token}`

**Query Params (all optional):**
- `startDate` - Filter from date
- `endDate` - Filter to date
- `page` - Page number (default: 1)
- `limit` - Records per page (default: 30)

**You get:**
```json
{
  "success": true,
  "data": {
    "records": [
      {
        "id": "ATT_001",
        "date": "2024-12-09",
        "status": "PRESENT",
        "checkIn": "2024-12-09T09:00:00Z",
        "checkOut": "2024-12-09T18:00:00Z",
        "hoursWorked": 9.0
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalRecords": 30
    }
  }
}
```

---

#### 3.5 Get Statistics
**`GET /api/attendance/statistics?period=month`**

**What it does:** Gets attendance stats like total hours, present days, etc.

**Headers:** `Authorization: Bearer {token}`

**Query Params (optional):**
- `period` - `month`, `quarter`, or `year` (default: `month`)

**You get:**
```json
{
  "success": true,
  "data": {
    "presentDays": 22,
    "totalHours": 180,
    "attendancePercentage": 92,
    "leavesTaken": 2,
    "absentDays": 0,
    "workingDays": 24
  }
}
```

---

#### 3.6 Get Monthly Chart Data
**`GET /api/attendance/monthly-chart?month=12&year=2024`**

**What it does:** Gets daily breakdown for monthly chart visualization.

**Headers:** `Authorization: Bearer {token}`

**Query Params:**
- `month` - Month number 1-12
- `year` - Year

**You get:**
```json
{
  "success": true,
  "data": {
    "month": 12,
    "year": 2024,
    "days": [
      {
        "date": "2024-12-01",
        "status": "WEEK_OFF",
        "hoursWorked": 0
      },
      {
        "date": "2024-12-02",
        "status": "PRESENT",
        "hoursWorked": 9.0
      }
    ]
  }
}
```

---

#### 3.7 Get Calendar Data
**`GET /api/attendance/calendar?month=12&year=2024`**

**What it does:** Gets attendance data for calendar view.

**Headers:** `Authorization: Bearer {token}`

**Query Params:**
- `month` - Month number 1-12
- `year` - Year

**You get:**
```json
{
  "success": true,
  "data": {
    "month": 12,
    "year": 2024,
    "days": [
      {
        "date": "2024-12-25",
        "status": "PRESENT",
        "isHoliday": true,
        "holidayName": "Christmas"
      }
    ]
  }
}
```

---

### 🏖️ 4. Leave Management APIs

#### 4.1 Apply for Leave
**`POST /api/leaves`**

**What it does:** Submits a new leave application.

**Headers:** `Authorization: Bearer {token}`

**Send:**
```json
{
  "leaveType": "SICK",
  "fromDate": "2024-12-15",
  "toDate": "2024-12-15",
  "reason": "Medical appointment",
  "numberOfDays": 1
}
```

**Leave Types:** `SICK`, `CASUAL`, `ANNUAL`, `EMERGENCY`

**You get:**
```json
{
  "success": true,
  "data": {
    "id": "LEAVE_001",
    "leaveType": "SICK",
    "fromDate": "2024-12-15",
    "toDate": "2024-12-15",
    "status": "PENDING",
    "numberOfDays": 1
  }
}
```

---

#### 4.2 Get Leave History
**`GET /api/leaves?status=PENDING&page=1&limit=20`**

**What it does:** Gets all leave applications with optional status filter.

**Headers:** `Authorization: Bearer {token}`

**Query Params (all optional):**
- `status` - `PENDING`, `APPROVED`, `REJECTED`, or `ALL` (default: `ALL`)
- `page` - Page number
- `limit` - Records per page

**You get:**
```json
{
  "success": true,
  "data": {
    "leaves": [
      {
        "id": "LEAVE_001",
        "leaveType": "SICK",
        "fromDate": "2024-12-15",
        "toDate": "2024-12-15",
        "status": "PENDING",
        "reason": "Medical appointment",
        "numberOfDays": 1
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalRecords": 6
    }
  }
}
```

---

#### 4.3 Get Leave Balances
**`GET /api/leaves/balances`**

**What it does:** Gets remaining leave balance for all leave types.

**Headers:** `Authorization: Bearer {token}`

**You get:**
```json
{
  "success": true,
  "data": {
    "SICK": {
      "total": 10,
      "used": 2,
      "available": 8
    },
    "CASUAL": {
      "total": 12,
      "used": 3,
      "available": 9
    },
    "ANNUAL": {
      "total": 20,
      "used": 5,
      "available": 15
    }
  }
}
```

---

#### 4.4 Cancel Leave
**`DELETE /api/leaves/:leaveId`**

**What it does:** Cancels a pending leave application.

**Headers:** `Authorization: Bearer {token}`

**Example:** `DELETE /api/leaves/LEAVE_001`

**You get:**
```json
{
  "success": true,
  "message": "Leave application cancelled successfully"
}
```

---

### 🔔 5. Notifications APIs

#### 5.1 Get Notifications
**`GET /api/notifications?unreadOnly=false&page=1&limit=20`**

**What it does:** Gets all notifications for the user.

**Headers:** `Authorization: Bearer {token}`

**Query Params (all optional):**
- `unreadOnly` - `true` or `false` (default: `false`)
- `page` - Page number
- `limit` - Records per page

**You get:**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "NOTIF_001",
        "title": "Leave Approved",
        "body": "Your sick leave has been approved.",
        "timestamp": "2024-12-10T14:30:00Z",
        "isRead": false,
        "type": "LEAVE_APPROVAL"
      }
    ],
    "unreadCount": 1,
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalRecords": 5
    }
  }
}
```

---

#### 5.2 Mark as Read
**`PUT /api/notifications/:notificationId/read`**

**What it does:** Marks one notification as read.

**Headers:** `Authorization: Bearer {token}`

**Example:** `PUT /api/notifications/NOTIF_001/read`

**You get:**
```json
{
  "success": true,
  "data": {
    "id": "NOTIF_001",
    "isRead": true
  }
}
```

---

#### 5.3 Mark All as Read
**`PUT /api/notifications/read-all`**

**What it does:** Marks all notifications as read.

**Headers:** `Authorization: Bearer {token}`

**You get:**
```json
{
  "success": true,
  "message": "All notifications marked as read",
  "data": {
    "updatedCount": 5
  }
}
```

---

#### 5.4 Get Unread Count
**`GET /api/notifications/unread-count`**

**What it does:** Gets count of unread notifications (for badge).

**Headers:** `Authorization: Bearer {token}`

**You get:**
```json
{
  "success": true,
  "data": {
    "unreadCount": 3
  }
}
```

---

### 📢 6. Announcements API

#### 6.1 Get Announcements
**`GET /api/announcements?pinnedOnly=false&page=1&limit=10`**

**What it does:** Gets announcements from managers.

**Headers:** `Authorization: Bearer {token}`

**Query Params (all optional):**
- `pinnedOnly` - `true` or `false` (default: `false`)
- `page` - Page number
- `limit` - Records per page

**You get:**
```json
{
  "success": true,
  "data": {
    "announcements": [
      {
        "id": "ANN_001",
        "title": "Team Meeting Tomorrow",
        "message": "Monthly team sync at 10:00 AM",
        "timestamp": "2024-12-09T13:00:00Z",
        "isPinned": true,
        "manager": {
          "id": "MGR001",
          "name": "John Manager",
          "avatarUrl": "https://storage.example.com/manager.jpg"
        }
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalRecords": 4
    }
  }
}
```

---

## 🎯 Implementation Priority

### Phase 1 - Must Have (11 APIs)
These are essential for the app to work:

1. **Authentication:** Login, Logout, Verify, Refresh
2. **User:** Get current user profile
3. **Attendance:** Check-in, Check-out, Today's status
4. **Stats:** Get attendance statistics
5. **Notifications:** Get notifications

### Phase 2 - Important (9 APIs)
These complete the main features:

1. Attendance history
2. Apply for leave
3. Leave history and balances
4. Get manager details
5. Announcements
6. Mark notification as read
7. Unread count
8. Monthly chart data

### Phase 3 - Nice to Have (4 APIs)
These add polish and convenience:

1. Update profile
2. Change password
3. Calendar data
4. Cancel leave

---

## 🔒 Security & Headers

### Authentication Required
All APIs except login need this header:
```
Authorization: Bearer {your_jwt_token}
```

### Error Response Format
When something goes wrong:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "What went wrong"
  }
}
```

**Common Error Codes:**
- `UNAUTHORIZED` - Token invalid or expired
- `FORBIDDEN` - No permission
- `VALIDATION_ERROR` - Invalid data sent
- `NOT_FOUND` - Resource doesn't exist
- `INTERNAL_ERROR` - Server problem

---

## 📝 Important Notes

1. **All dates/times** use ISO 8601 format (e.g., `2024-12-10T09:15:30Z`)
2. **All data** is sent and received in JSON format
3. **Pagination** works the same across all APIs
4. **Status codes:** 200 (OK), 201 (Created), 400 (Bad Request), 401 (Unauthorized), 404 (Not Found), 500 (Server Error)

---

**Document Version:** 2.0  
**Last Updated:** December 10, 2024  
**Total APIs:** 24 Endpoints
