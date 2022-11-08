Class {
	#name : #CoverageCollectorTest,
	#superclass : #TestCase,
	#category : #'Coverage-Tests'
}

{ #category : #example }
CoverageCollectorTest >> methodCallMethods [

	self methodEmpty.
	self methodOnlyReturn.
	self methodTwoPaths: true.
	self methodManyBlocks
]

{ #category : #example }
CoverageCollectorTest >> methodEmpty [
]

{ #category : #example }
CoverageCollectorTest >> methodManyBlocks [

	| i |
	i := 5.
	[ 1. i > 0 ] whileTrue: [ 2. i := i - 1 ].
	[ 3. i > 0 ] whileTrue: [ "not called" 4. i := i - 1 ].
	{ 0. 1 } collect: [ :j |
		| block |
		{ 0. 1 } do: [ :x | 6. x ].
		{ } do: [ :x | "not called" 7. x ].
		block := [ 8. ].
		block value.
		block := [ ].
		block value.
		block := [ "not called" 9. ].
		block := [ ] "not called".
		j ]
]

{ #category : #example }
CoverageCollectorTest >> methodNotCalled [
	
	^ 'Not expected to be called'
]

{ #category : #example }
CoverageCollectorTest >> methodOnlyReturn [

	^1
]

{ #category : #example }
CoverageCollectorTest >> methodTwoPaths: aBoolean [

	aBoolean ifTrue: [ 1 ].
	aBoolean ifTrue: [ ^2 ] ifFalse: [ 3 ].
	^4.
]

{ #category : #tests }
CoverageCollectorTest >> testBasicCoverage [

	| cov res |
	cov := CoverageCollector new.
	cov methods: { Rectangle>>#width. Rectangle>>#area. Rectangle>>#intersect: }.
	res := cov runOn: [ (1@1 corner: 2@2) area ].
	self assert: cov metalink hasNodes not. "metaliks where removed"
	self assert: res methods asSet equals: {Rectangle>>#width. Rectangle>>#area} asSet.
	self assert: res uncoveredMethods asArray equals: { Rectangle>>#intersect: }
]

{ #category : #tests }
CoverageCollectorTest >> testExaple [

	| collector coverage |
	collector := CoverageCollector new. "Instantiate"
	collector methods: Point methods, Rectangle methods.  "Configure with the methods to watch."	
	coverage := collector runOn: [ (1@1 corner: 2@2) center ].  "Setup, execute and teardown."
	self assert: (coverage methods includes: Point>>#x).  "Inspect the results"
	self assert: (coverage nodes size > 10). "Covered paths are also available"
]

{ #category : #tests }
CoverageCollectorTest >> testNoCoverage [

	| cov res |
	cov := CoverageCollector new.
	cov methods add: Rectangle>>#closeTo:.
	res := cov runOn: [ (1@1 corner: 2@2) area ].
	self assert: res methods size equals: 0.
	self assert: res percentage equals: 0.
]

{ #category : #tests }
CoverageCollectorTest >> testNodeCoverage [

	| cov res |
	cov := CoverageCollector new.
	cov methods add: self class>>#methodTwoPaths:.

	res := cov runOn: [ self methodTwoPaths: false. self methodTwoPaths: false. ].
	self assert: cov metalink hasNodes not. "metaliks where removed"
	self assert: cov methods size equals: 1.
	self assert: cov nodes size equals: 4.

	self assert: res methods size equals: 1.
	self assert: res nodes size equals: 2.
	self assert: (cov nodes includesAll: res nodes).
	self assert: res percentage asInteger equals: 50.
	self assert: res uncoveredNodes size equals: 2.
	
	res := cov runOn: [ self methodTwoPaths: true. self methodTwoPaths: true. ].
	self assert: (cov nodes includesAll: res nodes).
	self assert: res methods size equals: 1.
	self assert: res nodes size equals: 3.
	self assert: res percentage asInteger equals: 75.
	self assert: res uncoveredNodes size equals: 1.

	res := cov runOn: [ self methodTwoPaths: true. self methodTwoPaths: false. ].
	self assert: (cov nodes includesAll: res nodes).
	self assert: res methods size equals: 1.
	self assert: res nodes size equals: 4.
	self assert: res percentage asInteger equals: 100.
	self assert: res uncoveredNodes size equals: 0.

]

{ #category : #tests }
CoverageCollectorTest >> testNodeCoverage2 [

	| cov res |
	cov := CoverageCollector new.
	cov methods: (self class methods select: [ :m | 'method*' match: m selector ]).

	res := cov runOn: [ self methodCallMethods ].
	self assert: cov metalink hasNodes not. "metaliks where removed"
	self assert: cov methods size equals: 6.
	self assert: cov nodes size equals: 20.

	self assert: res methods size equals: 5.
	self assert: res nodes size equals: 14.
	self assert: (cov nodes includesAll: res nodes).
	self assert: res uncoveredNodes size equals: 6.
]

{ #category : #tests }
CoverageCollectorTest >> testNothingToCover [

	| cov res |
	cov := CoverageCollector new.
	res := cov runOn: [ (1@1 corner: 2@2) area ].
	self assert: res methods size equals: 0.
	self assert: res percentage isNaN.
]