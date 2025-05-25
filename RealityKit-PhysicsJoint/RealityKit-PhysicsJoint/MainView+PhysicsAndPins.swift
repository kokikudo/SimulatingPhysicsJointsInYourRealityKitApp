/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The methods that add physics, pins, and joints to each pendulum.
*/

import RealityKit

extension MainView {

    /// Performs physics setup for a pin joint between the ball and attachment entities.
    /// - Parameters:
    ///   - ballEntity: The ball entity to attach to the pendulum.
    ///   - attachmentEntity: The attachment entity to attach the pendulum to.
    func addPinsTo(ballEntity: Entity, attachmentEntity: Entity) throws {
        // Rotate hinge orientation from x to z-axis.
        let hingeOrientation = simd_quatf(from: [1, 0, 0], to: [0, 0, 1])

        // The attachment's pin is in the center of
        // the attachment entity.
        let attachmentPin = attachmentEntity.pins.set(
            named: "attachment_hinge",
            position: .zero,
            orientation: hingeOrientation
        )
        print("\(attachmentEntity.position)")
        print("\(attachmentPin.position)")

        // The ball's pin is at the center of the
        // attachment entity in local space.
        // ボールのPinの位置は天井の中心？なぜ？
        let relativeJointLocation = attachmentEntity.position(
            relativeTo: ballEntity
        )
        //ボール側のピンをずらしたら常に回転するようになった
        //relativeJointLocation += [-0.1, 0, 0]

        let ballPin = ballEntity.pins.set(
            named: "ball_hinge",
            position: relativeJointLocation,
            orientation: hingeOrientation
        )
        print("\(relativeJointLocation)")
        print("\(ballPin.position)")

        // Create a revolute joint between the two pins.
        // 2つのPinを繋いだPhysicsRevoluteJoint（物理回転ジョイント）を作成
        let revoluteJoint = PhysicsRevoluteJoint(pin0: attachmentPin, pin1: ballPin)
        // Add the joint to the simulation.
        /*
        ジョイントをシミュレーションに追加する
        pin0に設定したピンの祖先からPhysicsJointsComponentを持つEntityを再起的に探す
           -> あればそのEntityのPhysicsJointsComponentにジョイントを追加
           -> なければジョイントが参照する最初のEnitityにPhysicsJointsComponentを付与しジョイントに追加
        
         ここではルートに付与したPhysicsJointsComponentにジョイントが追加される
         */
        try revoluteJoint.addToSimulation()
    }

    /// Adds a physics body and collision component to the ball entity.
    ///
    /// - Parameter ballEntity: The ball entity to add physics to.
    /// 物理反応に必要なPhysicsBodyComponentとCollisionComponentをセット
    func addBallPhysics(to ballEntity: Entity) {
        let collisionShape = ShapeResource.generateSphere(
            radius: pendulumSettings.ballRadius)

        var ballBody = PhysicsBodyComponent(
            shapes: [collisionShape],
            mass: pendulumSettings.ballMass, // 質量(kg)
            material: .generate(staticFriction: 0.0, dynamicFriction: 0.0, restitution: 1.0),
            mode: .dynamic // 重力や衝突に反応させるために.dynamicを指定
        )
        ballBody.linearDamping = 0.0 // 摩擦なし

        let ballCollision = CollisionComponent(shapes: [collisionShape])

        ballEntity.components.set([ballBody, ballCollision])
    }

    /// Adds a physics body and collision component to the attachment entity.
    ///
    /// - Parameter attachmentEntity: The attachment entity to add physics to.
    func addAttachmentPhysics(to attachmentEntity: Entity) {
        let attachmentShape = ShapeResource.generateBox(
            size: pendulumSettings.attachmentSize * pendulumSettings.ballRadius
        )

        var attachmentBody = PhysicsBodyComponent(
            shapes: [attachmentShape], mass: 1.0,
            material: .generate(staticFriction: 0.0, dynamicFriction: 0.0, restitution: 1.0),
            mode: .static // 天井は動かないので.staticを指定
        )
        attachmentBody.linearDamping = 0.0

        let attachmentCollision = CollisionComponent(shapes: [attachmentShape])

        attachmentEntity.components.set([attachmentBody, attachmentCollision])
    }

    /// Performs an impulse action to push an entity.
    ///
    /// The impulse pushes the entity in the negative x-axis.
    ///
    /// - Parameter ballEntity: The entity to push.
    func pushEntity(_ ballEntity: Entity) throws {
        // Create a new impulse action.
        //  ImpulseActionにはCollisionComponentとPhysicsBodyComponentをEntityに付与し、PhysicsBodyComponentのmodeを.dynamicにしておく必要がある
        let impulseAction = ImpulseAction(
            targetEntity: .sourceEntity,
            linearImpulse: pendulumSettings.impulsePower
        )

        // Convert the impulse action to a playable animation.
        let impulseAnimation = try AnimationResource
            .makeActionAnimation(for: impulseAction)

        // Play the impulse action, which is
        // in the form of an animation resource.
        ballEntity.playAnimation(impulseAnimation)
    }
}
