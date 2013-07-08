# Mustache

Inspired by [ctemplate][1] and [et][2], Mustache is a
framework-agnostic way to render logic-free views.

As ctemplates says, "It emphasizes separating logic from presentation:
it is impossible to embed application logic in this template language."

For a list of implementations (other than XQuery) and tips, see
<http://mustache.github.com/>.

For a language-agnostic overview of Mustache’s template syntax, see the
`mustache(5)` manpage or <http://mustache.github.com/mustache.5.html>.

## Why?

Mustache.xq is designed to help you when you want to

1. avoid fn:concat to generate strings to keep your code more readable
2. easily generate non-xml output
3. use multiple backends (various xml and json styles)
4. migrate from other mustache dialects
5. separate your design from your logic
6. have a modular code-base

This Mustache.xq implementation works best with the XQuery processor
[BaseX][4]. It is a fork of the [MarkLogic specific mustache.xq][5] implementation.
Other standard comform XQuery processors should work correctly as well.

## Usage

First, copy the contents of the repo directory into your [BaseX Repository][6].

Next, run the following query:

``` xquery
    import module namespace mustache = "http://basex.org/modules/mustache/mustache";
    mustache:interpret-plain( mustache:parse('Hello {{text}}!'), '{ "text": "world"}', map { }, mustache:JSONinterpreter() )
```

Returns

``` xquery
    Hello world!
```

For more (fun) examples refer to "test/tests.xq". If you are new to mustache you can use it to learn more about it.
A full [rest-xq][7] based example can be found in the folder "example".

## Contribute

Everyone is welcome to contribute. 

1. Fork mustache.xq in github
2. Create a new branch - `git checkout -b my_branch`
3. Test your changes
4. Commit your changes
5. Push to your branch - `git push origin my_branch`
6. Create a pull request

Feel free to contribute to the wiki if you think something could be improved.

### Running the tests

To run the tests simply change your directory to the root of mustache.xq

    cd mustache.xq

Assuming you have installed BaseX in your system you can run the tests by executing:

    basex index.xq

Make sure all the tests pass before sending in your pull request!

### Report a bug

If you want to contribute with a test case please file an [issue][3] and attach 
the following information:

* Name
* Template
* Hash / Input
* Output

This will help us be faster fixing the problem.

An example for a Hello World test would be:

``` xml
     <test name="Hello World">
       <template>{'Hello {{word}}!'}</template>
       <hash interpreter="json">{'{"word": "world"}'}</hash>
       <output><div>Hello world!</div></output>
     </test>
```

This is not the actual test that we run (you can see a list of those in "test/tests.xq") but it's all the information we need for a bug report.

## Supported Functionality

####  ✔ Variables
     Template : {{car}}
     Hash     : { "car": "bmw"}
     Output   : bmw

####  ✔ Unescaped Variables
     Template : {{company}} {{{company}}}
     Hash     : { "company": "<b>BaseX</b>" }
     Output   : &lt;b&gt;BaseX&lt;/b&gt; <b>BaseX</b>

or

     Template : {{company}} {{&amp;company}}
     Hash     : { "company": "<b>BaseX</b>" }
     Output   : &lt;b&gt;BaseX&lt;/b&gt; <b>BaseX</b>

####  ✔ Sections with Non-False Values
     Template : Shown.{{#nothin}} Never shown!{{/nothin}}
     Hash     : { "person": true }
     Output   : Shown.

####  ✔ False Values or Empty Lists
     Template : Shown.{{#nothing}} Never shown!{{/nothing}}
     Hash     : { "different": true }
     Output   : Shown.

####  ✔ Nested Sections
     Template : {{#foo}}{{#a}}{{b}}{{/a}}{{/foo}}
     Hash     : { "foo": [ {"a": {"b": 1}}, {"a": {"b": 2}}, {"a": {"b": 3}} ] }
     Output   : 123

####  ✔ Non-Empty Lists
     Template : {{#repo}} <b>{{name}}</b> {{/repo}}
     Hash     : { "repo": [ { "name": "resque" }, { "name": "hub" }, { "name": "rip" } ] }
     Output   : <b>resque</b><b>hub</b><b>rip</b>

####  ✔ Inverted Sections
     Template : {{#repo}}<b>{{name}}</b>{{/repo}}{{^repo}}No repos :({{/repo}}
     Hash     : { "repo": [] }
     Output   : No Repos :(

####  ✔ Comments
     Template : <h1>Today{{! ignore me }}.</h1>
     Hash     : { }
     Output   : <h1>Today.</h1>

####  ✔ Partials
     Template : <h2>Names</h2>{{#names}}{{> partial_import.xq}}{{/names}}
     Hash     : { "names": [ { "name": "Peter" }, { "name": "Klaus" } ] }
     Output   : <h2>Names</h2><strong>Peter</strong><strong>Klaus</strong>

####  ✔ Set Delimiter
     Template : <h1>{{foo}}</h1><h2>{{=<% %>}}<%bar%></h2>
     Hash     : { "foo": "double mustaches", "bar": "ERB style" }
     Output   : <h1>double moustaches</h1><h2>ERB style</h2>

### Extensions

####  ✔ Dot Notation
     Template : {{person.name.first}}
     Hash     : { "person": { "name": { "first": "Eric" } } }
     Output   : Eric

####  ✔ Descendant Variable
     Template : * {{*name}}
     Hash     : { "people": { "person": { "name": "Chris" }, "name": "Jan" } }
     Output   : <div>* ChrisJan</div>

####  ✔ Function Calls
     Template : Entries: {{:count}}
     Hash     : { }
     Output   : Entries: 10

     Calls the function `count` which can be handed in via the `interpret` function.
     Please refer to the example folder for a complete example. The function
     may return any serializable value (in this case 10).

####  ✔ Non JSON inputs / hashs
     Template : {{car}}
     Hash     : <car>bmw</car>
     Output   : bmw

or

     Template : {{car}}
     Hash     : <entry name="car">bmw</entry>
     Output   : bmw

     This can be used by choosing another interpreter.
     Please refer to the example folder for a complete example.

### Known Limitations

In this section we have the know limitations excluding the features that are not supported. 
To better understand what is supported refer to the Supported Features section

* Key names that are no valid QNames may generate unexpected behaviour

## Meta

* Code: `git clone git://github.com/JosuaKrause/mustache.xq.git`
* Home: <http://mustache.github.com>
* Bugs: <http://github.com/JosuaKrause/mustache.xq/issues>

[1]: http://code.google.com/p/google-ctemplate/
[2]: http://www.ivan.fomichev.name/2008/05/erlang-template-engine-prototype.html
[3]: http://github.com/JosuaKrause/mustache.xq/issues
[4]: http://basex.org
[5]: http://github.com/dscape/mustache.xq
[6]: http://docs.basex.org/wiki/Options#REPOPATH
[7]: http://docs.basex.org/wiki/RESTXQ

