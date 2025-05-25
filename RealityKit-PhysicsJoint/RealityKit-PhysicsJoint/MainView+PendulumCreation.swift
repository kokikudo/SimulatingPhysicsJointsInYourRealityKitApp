/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The methods that create the pendulum scene.
*/

import SwiftUI
import RealityKit

/*
 用語まとめ
 Pendulum: ペンデュラム。玉、紐、天井をまとめた一つのオブジェクト。
 */

extension MainView {
    /// Creates a new pendulum entity, adds it to the content,
    /// and returns the pendulum entity.
    ///
    /// - Parameter content: The `RealityView` content that this method adds
    ///   the pendulum to.
    func buildPendulumScene(
        content: any RealityViewContentProtocol
    ) throws -> Entity {
        // ルートEntity
        let parentSimulationEntity = Entity()
        // ペンデュラムが入る親Entity
        let pendulumParent = Entity()
        parentSimulationEntity.addChild(pendulumParent)

        #if os(iOS) && !targetEnvironment(simulator)
        parentSimulationEntity.components.set(
            AnchoringComponent(.world(
                transform: Transform(translation: [0, 0, -1]).matrix
            ))
        )
        #endif

        content.add(parentSimulationEntity)
        
        /*
         物理シミュレーションを再現するためには対象のEntityの親にPhysicsSimulationComponentとPhysicsJointsComponentが必要
         (ここではルートEntity)
         */
        // Add physics simulation component to parent simulation entity.
        var simulationComponent = PhysicsSimulationComponent()
        simulationComponent.solverIterations.positionIterations = 25
        simulationComponent.solverIterations.velocityIterations = 25
        parentSimulationEntity.components.set(simulationComponent)
        // Add physics joints component to parent simulation entity.
        parentSimulationEntity.components.set(PhysicsJointsComponent())

        // Create pendulum entities and add them
        // to the parent simulation entity.
        // ペンデュラムの生成
        let firstPendulumX = -Float(pendulumSettings.pendulumCount - 1) / 2
        for pendulum in 0..<pendulumSettings.pendulumCount {
            
            // 親Entityを引数に渡すことで一つの親に複数の子を追加してる
            // 返り値のEntityは子Entityなので注意
            let newPendulum = createPendulum(pendulumParent)

            // Position all the pendulums this method creates next to each other,
            // along the x-axis.
            newPendulum.position.x = (
                firstPendulumX + Float(pendulum)
            ) * pendulumSettings.attachmentSize.x * pendulumSettings.ballRadius

            // @State変数に追加
            self.pendulums.append(newPendulum)
        }

        parentSimulationEntity.position.y = pendulumSettings.stringLength / 2

        // Simulation speed adjustments.
        let pendulumSpeed = pendulumSettings.pendulumSpeed
        assert(pendulumSpeed >= 0.5 && pendulumSpeed <= 1.5)
        // PhysicsSimulationComponentを付与したEntityのscaleでシミュレーションの速度が変わる？
        // それともスピードに合わせてscaleが変わる？？
        parentSimulationEntity.scale = simd_float3(repeating: pendulumSettings.pendulumSpeed)
        pendulumParent.scale = simd_float3(repeating: 1 / pendulumSettings.pendulumSpeed)

        return parentSimulationEntity
    }

    /// Creates and returns a pendulum entity.
    ///
    /// This method also adds the new pendulum entity as a child of `simulationParent`.
    ///
    /// - Parameter simulationParent: The parent entity to attach the pendulum to.
    func createPendulum(_ simulationParent: Entity) -> Entity {
        let pendulumParent = Entity()
        // Create all the pendulum pieces, and add them to
        // the pendulum structure.
        let ballEntity = makeBallEntity()
        pendulumParent.addChild(ballEntity)
        let stringEntity = makeStringEntity()
        ballEntity.addChild(stringEntity)
        let attachmentEntity = makeAttachmentEntity()
        pendulumParent.addChild(attachmentEntity)

        // Add physics components to the ball and attachment.
        // 物理反応を付与するためのコンポーネントをセット
        addBallPhysics(to: ballEntity)
        addAttachmentPhysics(to: attachmentEntity)

        // Add each pendulum to a common simulation parent
        // before adding the joint.
        // 親Entityに追加(joint?を追加する前に行う)
        simulationParent.addChild(pendulumParent)

        // Add a pin to the ball and attachment,
        // create a joint from the pins,
        // and add it to the simulation.
        // ボールと天井にPinを追加
        do {
            try addPinsTo(ballEntity: ballEntity, attachmentEntity: attachmentEntity)
        } catch {
            fatalError(error.localizedDescription)
        }

        return pendulumParent
    }
}
