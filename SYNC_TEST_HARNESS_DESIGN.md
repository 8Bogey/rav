# Sync Test Harness Design

## Purpose
Create a lightweight framework for testing sync metadata compatibility and validating bidirectional synchronization concepts without full implementation.

## Architecture Overview

### Core Components

#### 1. Mock Database Interfaces
```dart
class MockDriftDatabase {
  // Simulate Drift database operations
  // Include all sync metadata fields
  // Handle CRUD operations with sync states
}

class MockSupabaseDatabase {
  // Simulate Supabase database operations  
  // Mirror Drift interface for compatibility testing
  // Handle REST API interactions
}
```

#### 2. Sync Metadata Validator
```dart
class SyncMetadataValidator {
  // Validate field compatibility between databases
  // Check data type consistency
  // Verify null handling behavior
  // Test timestamp conversion logic
}
```

#### 3. Conflict Simulator
```dart
class ConflictSimulator {
  // Create artificial conflict scenarios
  // Test conflict detection mechanisms
  // Validate resolution approach effectiveness
}
```

#### 4. Test Data Generator
```dart
class TestDataGenerator {
  // Generate realistic test datasets
  // Create sync metadata variations
  // Simulate concurrent modifications
}
```

### Test Scenarios

#### Scenario 1: Basic Sync Compatibility
- **Objective**: Verify sync metadata fields work identically in both databases
- **Steps**:
  1. Create record in MockDrift with all sync metadata
  2. Transfer to MockSupabase
  3. Validate all fields match exactly
  4. Modify in MockSupabase and sync back
  5. Confirm bidirectional integrity

#### Scenario 2: Timestamp Handling
- **Objective**: Test timezone and precision differences
- **Steps**:
  1. Create record with specific timestamp in local timezone
  2. Convert to UTC for transfer
  3. Store in cloud database
  4. Retrieve and convert back to local
  5. Validate timestamp consistency

#### Scenario 3: Conflict Detection
- **Objective**: Validate conflict identification mechanisms
- **Steps**:
  1. Create identical record in both databases
  2. Modify locally (set dirtyFlag = true)
  3. Modify cloud version independently
  4. Attempt sync operation
  5. Verify conflict is detected via syncStatus

#### Scenario 4: Permissions Mask Processing
- **Objective**: Test selective sync capabilities
- **Steps**:
  1. Create records with different permissions masks
  2. Configure sync filters based on masks
  3. Verify only appropriate records sync
  4. Test edge cases (null masks, empty masks)

### Validation Metrics

#### Success Indicators
✅ All sync metadata fields transfer without corruption  
✅ Timestamp handling works across timezone boundaries  
✅ Conflict detection identifies 100% of artificial conflicts  
✅ Permissions masking effectively filters data subsets  
✅ Performance remains acceptable under test loads  

#### Failure Conditions
❌ Data type mismatches between databases  
❌ Loss of precision in timestamp transfers  
❌ Undetected conflicts leading to data inconsistency  
❌ Incorrect filtering based on permissions masks  
❌ Performance degradation exceeding thresholds  

### Implementation Approach

#### Phase 1: Foundation (Day 1 Morning)
1. Create mock database classes with sync metadata
2. Implement basic CRUD operations
3. Build sync metadata validator
4. Establish test data generation

#### Phase 2: Core Testing (Day 1 Afternoon)
1. Execute basic sync compatibility tests
2. Run timestamp handling validation
3. Test conflict detection scenarios
4. Document initial findings

#### Phase 3: Advanced Validation (Day 2 Morning)
1. Implement permissions mask testing
2. Create complex conflict scenarios
3. Test edge cases and error conditions
4. Validate performance characteristics

#### Phase 4: Reporting (Day 2 Afternoon)
1. Compile comprehensive findings report
2. Create implementation recommendations
3. Document technical challenges encountered
4. Prepare B08 implementation notes

### Risk Mitigation

#### Technical Risks
- **Incomplete mocking**: Focus on essential sync functionality only
- **Over-engineering**: Keep test harness minimal and focused
- **False positives**: Use multiple validation approaches

#### Time Management
- **Scope creep**: Strictly limit to compatibility validation
- **Analysis paralysis**: Time-box each testing phase
- **Documentation overload**: Focus on actionable insights

### Success Criteria

🎯 **Primary**: Validate that sync metadata foundation is solid  
🎯 **Secondary**: Identify 5+ specific technical challenges for B08  
🎯 **Tertiary**: Produce implementation guidance reducing B08 risk  

### Dependencies

None - completely self-contained proof of concept

### Deliverables

1. SYNC_VALIDATION_FINDINGS.md (already created)
2. B08_IMPLEMENTATION_NOTES.md (already created)  
3. This design document (SYNC_TEST_HARNESS_DESIGN.md)
4. Updated B08 task with implementation approach
5. Closed B13 task in Beads system

---
*Design document for Sync Validation Spike (B13)*
*Date: March 16, 2026*