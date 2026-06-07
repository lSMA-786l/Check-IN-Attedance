# AttendNova Backend Business Rules & Logic

This document details the logical operations, mathematics, and edge cases handled by the AttendNova REST API backend.

---

## 1. Geofencing Calculations (Haversine Formula)

For employees classified with `work_type = 'OFFICE'`, the backend performs an automated distance check against their assigned department’s geofence center before allowing a normal check-in.

### The Mathematics:
Because the Earth is a sphere, simple Pythagorean flat-plane distance calculations (`x^2 + y^2 = d^2`) are inaccurate over coordinates. The backend implements the **Haversine Formula** to compute the shortest great-circle distance between two GPS coordinates:

$$a = \sin^2\left(\frac{\Delta\phi}{2}\right) + \cos(\phi_1)\cos(\phi_2)\sin^2\left(\frac{\Delta\lambda}{2}\right)$$

$$c = 2\cdot\text{atan2}\left(\sqrt{a}, \sqrt{1-a}\right)$$

$$d = R\cdot c$$

Where:
*   $\phi$ = Latitude in radians.
*   $\lambda$ = Longitude in radians.
*   $R$ = Earth's radius (6,371,000 meters).
*   $d$ = Resulting distance in meters.

### In-Code Implementation:
We implement this in [attendance.py](file:///d:/NOVA/flutter_st/attendnova_3/backend/app/routes/attendance.py#L15-L33):
```python
def calculate_haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371000.0  # Earth's radius in meters
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = (math.sin(delta_phi / 2.0) ** 2 +
         math.cos(phi1) * math.cos(phi2) *
         math.sin(delta_lambda / 2.0) ** 2)
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return R * c
```

### Out-of-Bounds Flagging Rules:
*   If $d \le \text{allowed\_radius\_meters}$ (default 100 meters), the session is marked:
    *   `is_out_of_bounds = False`
    *   `verification_status = 'APPROVED'`
*   If $d > \text{allowed\_radius\_meters}$, the check-in is **not blocked** (to prevent GPS drift lockout). Instead, it is logged with:
    *   `is_out_of_bounds = True`
    *   `verification_status = 'PENDING_APPROVAL'`
    *   This alerts managers in their approval queue to review and authorize/reject the session manually.

---

## 2. Night-Shift Date Mapping (Overnight Boundaries)

Night shifts span across calendar midnights (e.g., clocking in Monday at 10:00 PM and clocking out Tuesday at 6:00 AM). 

### The Problem:
If we assign the calendar date of the clock-in as the unique identifier for a session, checking out on Tuesday morning works fine. But when the user tries to clock back in for their next shift on Tuesday night at 10:00 PM, they will encounter unique constraint key violations (as they are clocking in on the same calendar day twice).

### The Solution:
We calculate a logical `shift_date` that represents the start date of the work cycle. 

If the employee’s assigned shift spans across midnight (i.e. `end_time < start_time`):
*   We check the clock-in hour.
*   If the user clocks in early in the morning (between **12:00 AM and 8:00 AM**), we logically map their `shift_date` to **yesterday's date** (since they are clocking in late for the night shift that began the previous evening).
*   Otherwise, the shift date is **today's date**.

We implement this in [attendance.py](file:///d:/NOVA/flutter_st/attendnova_3/backend/app/routes/attendance.py#L35-L50):
```python
def calculate_shift_date(clock_in_time: datetime, shift: Optional[models.Shift]) -> date:
    if not shift:
        return clock_in_time.date()
    if shift.end_time < shift.start_time:
        if clock_in_time.hour < 8:
            return (clock_in_time - timedelta(days=1)).date()
    return clock_in_time.date()
```

---

## 3. Work-Type Execution Matrix

| Employee Work Type | Geofencing Checked? | Timeline Activity Logs Active? | Description / Handled Logic |
| :--- | :---: | :---: | :--- |
| **`OFFICE`** | **Yes** | No | Subject to the 100m distance validation. Bypasses activity detail logs. |
| **`FIELD`** | No | **Yes** | Exempt from geofence checks. Check-in automatically starts an initial `TRAVEL` log. Activity transitions (e.g. `MEETING`, `BREAK`) are logged. |
| **`REMOTE`** | No | No | Clock-in from anywhere is automatically `APPROVED`. Keeps timeline logs simple and clean. |

---

## 4. Timeline Activity State Machine (Field Workers)

Field workers construct a chronological timeline of their workday by toggling activities (`TRAVEL`, `MEETING`, `WORK`, `BREAK`).

### State Rules:
*   Only **one** activity can be open (`end_time IS NULL`) at any given moment for a user session.
*   **Initial State**: Check-in automatically boots a `TRAVEL` log with `start_time = clock_in`.
*   **State Transition (`POST /api/attendance/activity`)**:
    1.  Locate the current active log where `end_time IS NULL`.
    2.  Set its `end_time = now`.
    3.  Create a new `ActivityLog` record with the new activity type and `start_time = now`.
*   **Checkout State**: Clocking out automatically terminates the final active activity log by setting its `end_time = clock_out`.
