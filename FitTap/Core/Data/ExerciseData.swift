import Foundation

/// The built-in exercise catalog, grouped by muscle group. Copied into the
/// database on launch (`SwiftDataManager.seedBuiltInExercises`). Every entry
/// has a fixed id, the same on every install, so logged sets keep pointing
/// at the right exercise and an update can add new built-ins. Never change
/// an existing id.
enum ExerciseData {
    static let exercises: [Exercise] = chest + back + shoulders + legs + arms + abs + cardio

    // MARK: - Chest

    private static let chest: [Exercise] = [
        Exercise(id: UUID(uuidString: "5C4217A5-AE06-4C06-BA6C-028242234F79")!, name: "Bench Press", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .chest, secondaryMuscleGroup: .triceps),
        Exercise(id: UUID(uuidString: "64BC5B81-A894-4CB2-801B-E86D253CBD03")!, name: "Incline Bench", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .chest, secondaryMuscleGroup: .shoulders),
        Exercise(id: UUID(uuidString: "1F118244-4C02-4C3C-A4FC-5A9320C52205")!, name: "Chest Dips", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .chest, secondaryMuscleGroup: .triceps),
        Exercise(id: UUID(uuidString: "AB2E27BE-1946-4C11-A096-DF7C031E1515")!, name: "DB Flies", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .chest),
        Exercise(id: UUID(uuidString: "0611A730-0158-491C-AB5E-733290F51B7F")!, name: "DB Incline Press", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .chest, secondaryMuscleGroup: .shoulders),
        Exercise(id: UUID(uuidString: "6C59EF93-F44D-4851-A126-6F2DD93CE3B1")!, name: "Fly Machine", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .chest),
        Exercise(id: UUID(uuidString: "F6793626-E359-4F80-816F-63FAB63E7F39")!, name: "Chest Machine", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .chest, secondaryMuscleGroup: .triceps),
    ]

    // MARK: - Back

    private static let back: [Exercise] = [
        Exercise(id: UUID(uuidString: "DBECDF86-F101-4745-9320-B054E12D7A46")!, name: "Deadlift", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .back, secondaryMuscleGroup: .legs),
        Exercise(id: UUID(uuidString: "E35860F4-5EFD-471A-804B-EDAF2E13020C")!, name: "Pull-Ups", kind: .bodyweight, equipment: .pullUpBar, mainMuscleGroup: .back, secondaryMuscleGroup: .biceps),
        Exercise(id: UUID(uuidString: "09254DBA-C4FC-4390-8801-81EDCD408120")!, name: "Bent-Over Row", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .back),
        Exercise(id: UUID(uuidString: "F4453E14-EAC1-49C2-B49A-F5385EA9399A")!, name: "Low Row Machine", kind: .weightlifting, loadMode: .perSide, equipment: .machine, mainMuscleGroup: .back),
        Exercise(id: UUID(uuidString: "67F809D7-E3B0-4B14-9F38-9AA5CA9D9770")!, name: "Row Machine", kind: .weightlifting, loadMode: .perSide, equipment: .machine, mainMuscleGroup: .back),
    ]

    // MARK: - Shoulders

    private static let shoulders: [Exercise] = [
        Exercise(id: UUID(uuidString: "FC7FF061-3C16-4CC0-B999-4E3E73A82A48")!, name: "Standing OHP", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .shoulders, secondaryMuscleGroup: .triceps),
        Exercise(id: UUID(uuidString: "B35EBFEC-08AB-4431-B446-4DD2773C3383")!, name: "Push Press", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .shoulders),
        Exercise(id: UUID(uuidString: "2D82D353-A832-4F11-A7AC-7A1193384ED3")!, name: "Arnold Press", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .shoulders),
        Exercise(id: UUID(uuidString: "404FC337-7504-4E7F-BB76-5BAA36D5713F")!, name: "DB Lateral Raises", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .shoulders),
        Exercise(id: UUID(uuidString: "FA6B7778-FD43-486F-8B3A-41DE89A138E8")!, name: "Rear Delt Fly", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .shoulders),
        Exercise(id: UUID(uuidString: "F8E65EC7-F4E5-44EF-B83D-4ADC40AA4CFF")!, name: "EZ Bar High Pull", kind: .weightlifting, loadMode: .perSide, equipment: .ezBar, mainMuscleGroup: .shoulders, secondaryMuscleGroup: .back),
        Exercise(id: UUID(uuidString: "6C61A715-90CB-4166-9401-4B89FD4B4281")!, name: "Shoulder Press Machine", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .shoulders),
    ]

    // MARK: - Legs

    private static let legs: [Exercise] = [
        Exercise(id: UUID(uuidString: "9A50D61F-73DD-4F48-AC52-C6E0B1E6EDB5")!, name: "Back Squat", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .legs),
        Exercise(id: UUID(uuidString: "13A25741-A256-4EF5-96F8-F86DA28F64C2")!, name: "RDL", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .legs, secondaryMuscleGroup: .back),
        Exercise(id: UUID(uuidString: "23CB7014-47D7-4F9A-B1D6-3A219D15C20A")!, name: "Bulgarian Split Squat", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .legs),
        Exercise(id: UUID(uuidString: "854B2F26-6E5F-457F-BCEB-B9E492FA6CBA")!, name: "Leg Extension", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .legs),
        Exercise(id: UUID(uuidString: "C0789ACC-4D03-4EEF-BD87-6BC4600833C8")!, name: "Leg Press", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .legs),
        Exercise(id: UUID(uuidString: "03FC6B22-E140-4455-96CC-2D8F02CD90BD")!, name: "Leg Curls", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .legs),
        Exercise(id: UUID(uuidString: "13560CB4-416B-4AF9-8262-5A4FFEE38318")!, name: "Calf Raises", kind: .weightlifting, loadMode: .perSide, equipment: .machine, mainMuscleGroup: .legs),
        Exercise(id: UUID(uuidString: "6433E897-6BF5-45C0-993D-7C6BB184F1F7")!, name: "Wall Sit", kind: .hold, equipment: .bodyweight, mainMuscleGroup: .legs),
    ]

    // MARK: - Arms

    private static let arms: [Exercise] = [
        Exercise(id: UUID(uuidString: "8EA3DB2B-B341-4961-A59C-7574539B8289")!, name: "DB Curls", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .biceps),
        Exercise(id: UUID(uuidString: "CE15B095-4188-417B-A55F-940C6BFD9BA1")!, name: "EZ Bar Curls", kind: .weightlifting, loadMode: .perSide, equipment: .ezBar, mainMuscleGroup: .biceps),
        Exercise(id: UUID(uuidString: "9C232F42-AF9C-4E20-B1F1-B5FB17BA195B")!, name: "Tricep Pushdowns", kind: .weightlifting, loadMode: .machineStack, equipment: .cable, mainMuscleGroup: .triceps),
        Exercise(id: UUID(uuidString: "2C98C018-E8F4-4EFA-B06A-7DFE5BF9D2AA")!, name: "EZ Skull Crushers", kind: .weightlifting, loadMode: .perSide, equipment: .ezBar, mainMuscleGroup: .triceps),
        // One dumbbell held in both hands, so the number is the whole weight.
        Exercise(id: UUID(uuidString: "0B4E548F-7663-4D12-9E63-9FE20B8061D9")!, name: "Tricep Overhead Extension", kind: .weightlifting, loadMode: .total, equipment: .dumbbell, mainMuscleGroup: .triceps),
    ]

    // MARK: - Abs

    private static let abs: [Exercise] = [
        Exercise(id: UUID(uuidString: "56FDF96F-9934-4CD4-8ED7-6718BC6699F6")!, name: "Sit-Ups", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(id: UUID(uuidString: "0FC501F7-4F7D-4A6E-B718-ED6A11986EE8")!, name: "Decline Sit-Ups", kind: .bodyweight, equipment: .bench, mainMuscleGroup: .abs),
        Exercise(id: UUID(uuidString: "0D00C40B-7D8A-49E2-892E-75F95640E3BA")!, name: "Crunches", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(id: UUID(uuidString: "4DDE38D7-B177-4C25-8B0A-7FC2E6162A0D")!, name: "Bicycle Crunches", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(id: UUID(uuidString: "3A0DD6CF-3CEE-4F44-B0AC-3C324AB2C516")!, name: "Russian Twists", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(id: UUID(uuidString: "78F75979-FD79-4452-8D30-087DBAB21E3C")!, name: "Lying Leg Raises", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(id: UUID(uuidString: "BC69741E-B691-42A0-B5C3-7B2F72C239B6")!, name: "Hanging Leg Raises", kind: .bodyweight, equipment: .pullUpBar, mainMuscleGroup: .abs),
        Exercise(id: UUID(uuidString: "18005DC9-48E3-46F2-BB66-F39428999D70")!, name: "Ab Wheel Rollout", kind: .bodyweight, equipment: .other, mainMuscleGroup: .abs),
        Exercise(id: UUID(uuidString: "A1C5FACF-69A2-466D-A56D-89F8B44BD72C")!, name: "Cable Crunch", kind: .weightlifting, loadMode: .machineStack, equipment: .cable, mainMuscleGroup: .abs),
        // Timed hold — logged as a duration.
        Exercise(id: UUID(uuidString: "E0EDF19D-A9F1-4B69-AE0B-13B63C1C8D4D")!, name: "Plank", kind: .hold, equipment: .bodyweight, mainMuscleGroup: .abs),
    ]

    // MARK: - Cardio

    private static let cardio: [Exercise] = [
        Exercise(id: UUID(uuidString: "AF01A92B-86DD-4F62-A665-35E462E30C62")!, name: "Running", kind: .cardio, equipment: .bodyweight),
        Exercise(id: UUID(uuidString: "F715B090-24BE-4D89-B50C-A0910E6BAC28")!, name: "Walking", kind: .cardio, equipment: .bodyweight),
        Exercise(id: UUID(uuidString: "59F09B45-7E46-4B06-BA85-B98974FD0286")!, name: "Jump Rope", kind: .cardio, equipment: .other),
        Exercise(id: UUID(uuidString: "6DA83C79-C2D3-4766-81C0-433322FA7227")!, name: "Cycling", kind: .cardio, equipment: .machine),
        Exercise(id: UUID(uuidString: "0D6C9751-94AA-4ABC-AEB6-F66C2BDADC0E")!, name: "Rowing", kind: .cardio, equipment: .machine),
        Exercise(id: UUID(uuidString: "88C8BA09-60FD-4BD6-83F4-6827C3BA3077")!, name: "Elliptical", kind: .cardio, equipment: .machine),
        Exercise(id: UUID(uuidString: "91BD7F41-0567-42C4-A853-AC9036DFC1C2")!, name: "Stair Climber", kind: .cardio, equipment: .machine),
        Exercise(id: UUID(uuidString: "E22FF97F-9A92-4293-8AEF-A9722B1F4DDA")!, name: "Swimming", kind: .cardio, equipment: .bodyweight),
        Exercise(id: UUID(uuidString: "50EC8B52-2B57-4FC3-8753-C771AC9972F7")!, name: "Boxing", kind: .cardio, equipment: .other),
        Exercise(id: UUID(uuidString: "7131C2CC-248A-4660-985A-B2AD36664253")!, name: "MMA", kind: .cardio, equipment: .other),
    ]
}
