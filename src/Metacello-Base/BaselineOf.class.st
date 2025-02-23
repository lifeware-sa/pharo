"
You should use a *baseline* when you are using a disk-based source
code manager (SCM) like [git][1].

When using a disk-based SCM it is not necessary to use the Metacello
*version* method, because it is intended for use with `.mcz` files. 

With a disk-based SCM you only need a single `baseline:` method. When
you change the structure of your project you can change the baseline and
save everything in a single commit. So multiple `baseline:` methods are
no longer needed.

You may still need a *configuration* when using a *baseline*. The
[Sample project][3] on GitHub has a good example of a configuration used
in conjunction with a *baseline*. See the [**ConfigurationOf** class comment][2] 
for information on creating a *configuration*.

To create a new Metacello baseline:

1. Create a subclass of the **BaselineOf** class. The baseline
   class for your project should be named by appending the name of
   your project to the string `BaselineOf`. The name of the category and
   package should be the same as the name of the class:

    ```Smalltalk
    BaselineOf subclass: #BaselineOfExample
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'BaselineOfExample'
    ```

2. Create a **baseline:** method where you specify the structure of your project:

    ```Smalltalk
    baseline: spec
      <baseline>

      spec for: #common do: [
        spec
          package: 'Example-Core';
          package: 'Example-Tests' with: [
            spec requires: 'Example-Core' ]].
    ```

3. Create a Monticello package for your **BaselineOf** class and save it in the repository where your packages are stored.

4. To load a package from GitHub that contains a baseline evaluate the following:

```Smalltalk
| repositorySpec |
""edit to match your username, repository name and branch""
repositorySpec := 'dalehenrich/metacello-work:master'.
Metacello new
  baseline: 'Sample';
  repository: 'github://', repositorySpec;
  load.
```

For further documentation see For more information on the [github://](MetacelloScriptingAPI.md#github) url specifigation see the [Metacello Scripting API
reference](MetacelloScriptingAPI.md). There more information on [working with GitHub here](GettingStartedWithGitHub.md).

[1]: http://git-scm.com/
[2]: https://github.com/dalehenrich/metacello-work/blob/master/repository/Metacello-Base.package/ConfigurationOf.class/README.md
[3]: https://github.com/dalehenrich/sample/tree/configuration/ConfigurationOfSample.package/ConfigurationOfSample.class

"
Class {
	#name : #BaselineOf,
	#superclass : #ConfigurationOf,
	#category : #'Metacello-Base'
}

{ #category : #accessing }
BaselineOf class >> validate [
  "Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

  "self validate"

  <apiDocumentation>
  self ensureMetacello.
  ^ ((self environment at: #'MetacelloToolBox')
    validateBaseline: self
    debug: #()
    recurse: false) inspect
]

{ #category : #baselines }
BaselineOf >> baseline: spec [
	<baseline>
	"subclasses should redefine me"
	
	"Here is a typical package and its tests
	spec for: #'common' do: [
		spec 
			package: #'XXX-Core';
			package: #'XXX-Core-Tests' with: [
				spec requires: #('XXX-Core' ) ].
		spec 
			group: 'Core' with: #('XXX-Core' );
			group: 'CoreTests' with: #('XXX-Core' 'XXX-Core-Tests');
			group: 'default' with: #('Beacon-XXX' 'Beacon-XXX-Tests') ]
	"
]

{ #category : #accessing }
BaselineOf >> projectClass [
    ^ MetacelloMCBaselineProject
]

{ #category : #accessing }
BaselineOf >> versionNumberClass [
    ^ MetacelloVersionNumber
]
