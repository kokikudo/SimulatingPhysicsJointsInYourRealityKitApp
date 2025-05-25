//
//  Memo.swift
//  Physics Joint RealityKit
//
//  Created by kudo koki on 2025/05/25.
//  Copyright © 2025 Apple. All rights reserved.
//

/*
 用語解説
 PhysicsSimulationComponent: アプリで物理シミュレートするためのコンポーネント。重力や衝突オプションプロパティを設定してさまざまな環境を構築できる。シミュレート対象のEntityの親に付与する。距離の単位はメートル（重要）
 PhysicsJointsComponent: RealityKit がシミュレートする物理ジョイントを保存するコンポーネント。上記コンポーネントと合わせて付与する。実際の保存処理はPhysicsJoint.addToSimulation()で物理ジョイントを追加する
 PhysicsJoint: 物理ジョイントを定義するプロトコル。今回の例はこのプロトコルに準拠したPhysicsRevoluteJoint（回転制御のジョイント）を採用してる。pin0とpin1を設定し、pin0に対するpin1の動きを定義する。
 PhysicsBodyComponent: Entityに物理特性を付与するコンポーネント。摩擦や質量などを設定できる。modeには動きを制御するモードを設定できる(static: 動かない, kinematic: ユーザー制御, dynamic: 他の物体との衝突)。物理ジョイントを実装するには対象のEntity(この例では球体と天井)にこのコンポーネントとCollisionComponentを付ける
 ImpulseAction
 
 */


/*
 疑問点
 ボールのPinはなぜ天井の中心に設定してる？
 */
