Class {
	#name : #AllTestFailTest,
	#superclass : #UtilityTest,
	#category : #'TestRunner-Tests-Utilities-Test'
}

{ #category : #tests }
AllTestFailTest >> testFail1 [

	self shouldBeIgnored ifTrue: [ ^ self ].
	self assert: false
]

{ #category : #tests }
AllTestFailTest >> testFail2 [

	self shouldBeIgnored ifTrue: [ ^ self ].
	self assert: false
]

{ #category : #tests }
AllTestFailTest >> testFail3 [

	self shouldBeIgnored ifTrue: [ ^ self ].
	self assert: false
]

{ #category : #tests }
AllTestFailTest >> testFail4 [

	self shouldBeIgnored ifTrue: [ ^ self ].
	self assert: false
]