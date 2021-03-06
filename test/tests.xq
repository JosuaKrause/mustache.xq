<tests>
  <test name="Variables" section="etag">
    <template>{'Hello {{word}}!'}</template>
    <hash interpreter="json">{'{"word": "world"}'}</hash>
    <hash interpreter="xmlf"><word>world</word></hash>
    <hash interpreter="xmls"><entry name="word">world</entry></hash>
    <output><div>Hello world!</div></output>
    <parseTree>
      <multi>
        <static>Hello </static>
        <etag name="word"/>
        <static>!</static>
      </multi>
    </parseTree>
  </test>
  <test name="Two mustaches With No Whitespace" section="whitespace">
    <template>{'{{word}}{{word}}!'}</template>
    <hash interpreter="json">{'{"word": "la"}'}</hash>
    <hash interpreter="xmlf"><word>la</word></hash>
    <hash interpreter="xmls"><entry name="word">la</entry></hash>
    <output><div>lala!</div></output>
    <parseTree>
      <multi>
        <etag name="word"/>
        <etag name="word"/>
        <static>!</static>
      </multi>
    </parseTree>
  </test>
  <test name="Variables with embedded XQuery" section="etag">
    <template>{'x=4+5*2={{x}}'}</template>
    <hash interpreter="json">{'{ "x": ' || ( xs:integer(4) + 5 ) * 2 || '}'}</hash>
    <hash interpreter="xmlf"><x>{ ( xs:integer(4) + 5 ) * 2 }</x></hash>
    <hash interpreter="xmls"><entry name="x">{ (xs:integer(4) + 5 ) * 2 }</entry></hash>
    <output><div>x=4+5*2=18</div></output>
    <parseTree>
      <multi>
        <static>x=4+5*2=</static>
        <etag name="x"/>
      </multi>
    </parseTree>
  </test>
  <test name="Escaped Variables with {'{{{var}}}'}" section="utag">
    <template>{'* {{name}}
    * {{age}}
    * {{company}}
    * {{{company}}}'}</template>
    <hash interpreter="json">{'{
      "name": "Chris",
      "company": "<b>GitHub</b>"
    }'}</hash>
    <hash interpreter="xmlf"><name>Chris</name><company><b>GitHub</b></company></hash>
    <hash interpreter="xmls"><entry name="name">Chris</entry><entry name="company"><b>GitHub</b></entry></hash>
    <output>
      <div>
        * Chris
        *
        * &lt;b&gt;GitHub&lt;/b&gt;
        * <b>GitHub</b>
      </div>
    </output>
    <parseTree>
      <multi>
        <static>* </static>
        <etag name="name"/>
        <static>* </static>
        <etag name="age"/>
        <static>* </static>
        <etag name="company"/>
        <static>* </static>
        <utag name="company"/>
      </multi>
    </parseTree>
  </test>
  <test name="Simple Escaped Variables with {{&amp;var}}" section="utag">
    <template>{'{{&amp; name}}'}</template>
    <hash interpreter="json">{'{"name":"<b>Pete Aven</b>"}'}</hash>
    <hash interpreter="xmlf"><name><b>Pete Aven</b></name></hash>
    <hash interpreter="xmls"><entry name="name"><b>Pete Aven</b></entry></hash>
    <output><div><b>Pete Aven</b></div></output>
    <parseTree>
      <multi>
        <utag name="name"/>
      </multi>
    </parseTree>
  </test>
  <test name="Escaped Variables with {{&amp;var}}" section="utag">
    <template>{'* {{name}}
    * {{age}}
    * {{company}}
    * {{&amp;company}}'}</template>
    <hash interpreter="json">{'{
      "name": "Chris",
      "company": "<b>GitHub</b>"
    }'}</hash>
    <hash interpreter="xmlf"><name>Chris</name><company><b>GitHub</b></company></hash>
    <hash interpreter="xmls"><entry name="name">Chris</entry><entry name="company"><b>GitHub</b></entry></hash>
    <output>
      <div>
        * Chris
        *
        * &lt;b&gt;GitHub&lt;/b&gt;
        * <b>GitHub</b>
      </div>
    </output>
    <parseTree>
      <multi>
        <static>* </static>
        <etag name="name"/>
        <static>* </static>
        <etag name="age"/>
        <static>* </static>
        <etag name="company"/>
        <static>* </static>
        <utag name="company"/>
      </multi>
    </parseTree>
  </test>
  <test name="Missing Sections" section="section">
    <template>{'Shown.
    {{#nothin}}
      Never shown!
    {{/nothin}}'}</template>
    <hash interpreter="json">{'{
      "person": true
    }'}</hash>
    <hash interpreter="xmlf"><person>true</person></hash>
    <hash interpreter="xmls"><entry name="person">true</entry></hash>
    <output><div>Shown.</div></output>
    <parseTree>
      <multi>
        <static>Shown.</static>
        <section name="nothin">
          <static>Never shown!</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="True Sections" section="section">
    <template>{'Shown.
    {{#nothin}}
      Also shown!
    {{/nothin}}'}</template>
    <hash interpreter="json">{'{
      "nothin": true
    }'}</hash>
    <hash interpreter="xmlf"><nothin>true</nothin></hash>
    <hash interpreter="xmls"><entry name="nothin">true</entry></hash>
    <output><div>Shown. Also shown!</div></output>
    <parseTree>
      <multi>
        <static>Shown.</static>
        <section name="nothin">
          <static>Also shown!</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="False Sections" section="section">
    <template>{'Shown.
    {{#nothin}}
      Never shown!
    {{/nothin}}'}</template>
    <hash interpreter="json">{'{
      "nothin": false
    }'}</hash>
    <hash interpreter="xmlf"><nothin>false</nothin></hash>
    <hash interpreter="xmls"><entry name="nothin">false</entry></hash>
    <output><div>Shown.</div></output>
    <parseTree>
      <multi>
        <static>Shown.</static>
        <section name="nothin">
          <static>Never shown!</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Empty Lists Sections" section="section">
    <template>{'Shown.
    {{#nothin}}
      Never shown!
    {{/nothin}}'}</template>
    <hash interpreter="json">{'{
      "nothin": []
    }'}</hash>
    <hash interpreter="xmlf"><nothin /></hash>
    <hash interpreter="xmls"><entry name="nothin" /></hash>
    <output><div>Shown.</div></output>
    <parseTree>
      <multi>
        <static>Shown.</static>
        <section name="nothin">
          <static>Never shown!</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Non-empty Lists Sections" section="section">
    <template>{'{{#repo}}
    <b>{{name}}</b>
  {{/repo}}'}</template>
    <hash interpreter="json">{'{
      "repo": [
        { "name": "resque" },
        { "name": "hub" },
        { "name": "rip" }
      ]
    }'}</hash>
    <hash interpreter="xmlf">
      <repo><name>resque</name></repo>
      <repo><name>hub</name></repo>
      <repo><name>rip</name></repo>
    </hash>
    <hash interpreter="xmls">
      <entry name="repo"><entry name="name">resque</entry></entry>
      <entry name="repo"><entry name="name">hub</entry></entry>
      <entry name="repo"><entry name="name">rip</entry></entry>
    </hash>
    <output>
      <div>
        <b>resque</b>
        <b>hub</b>
        <b>rip</b>
      </div>
    </output>
    <parseTree>
      <multi>
        <section name="repo">
          <static>&lt;b&gt;</static>
          <etag name="name"/>
          <static>&lt;/b&gt;</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Array of Strings" section="section">
    <template>{'{{#array_of_strings}} {{.}}! {{/array_of_strings}}'}</template>
    <hash interpreter="json">{'{"array_of_strings": ["hello", "world"]}'}</hash>
    <hash interpreter="xmlf">
      <array_of_strings>hello</array_of_strings>
      <array_of_strings>world</array_of_strings>
    </hash>
    <hash interpreter="xmls">
      <entry name="array_of_strings">hello</entry>
      <entry name="array_of_strings">world</entry>
    </hash>
    <output><div>hello! world!</div></output>
    <parseTree>
      <multi>
        <section name="array_of_strings">
          <etag name="."/>
          <static>!</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Missing Inverted Sections" section="inverted-section">
    <template>{'Shown.
    {{^nothin}}
      Also shown!
    {{/nothin}}'}</template>
    <hash interpreter="json">{'{
      "person": true
    }'}</hash>
    <hash interpreter="xmlf"><person>true</person></hash>
    <hash interpreter="xmls"><entry name="person">true</entry></hash>
    <output><div>Shown. Also shown!</div></output>
    <parseTree>
      <multi>
        <static>Shown.</static>
        <inverted-section name="nothin">
          <static>Also shown!</static>
        </inverted-section>
      </multi>
    </parseTree>
  </test>
  <test name="True Inverted Sections" section="inverted-section">
    <template>{'Shown.
    {{^nothin}}
      Not shown!
    {{/nothin}}'}</template>
    <hash interpreter="json">{'{
      "nothin": true
    }'}</hash>
    <hash interpreter="xmlf"><nothin>true</nothin></hash>
    <hash interpreter="xmls"><entry name="nothin">true</entry></hash>
    <output><div>Shown.</div></output>
    <parseTree>
      <multi>
        <static>Shown.</static>
        <inverted-section name="nothin">
          <static>Not shown!</static>
        </inverted-section>
      </multi>
    </parseTree>
  </test>
  <test name="False Inverted Sections" section="inverted-section">
    <template>{'Shown.
    {{^nothin}}
      Also shown!
    {{/nothin}}'}</template>
    <hash interpreter="json">{'{
      "nothin": false
    }'}</hash>
    <hash interpreter="xmlf"><nothin>false</nothin></hash>
    <hash interpreter="xmls"><entry name="nothin">false</entry></hash>
    <output><div>Shown. Also shown!</div></output>
    <parseTree>
      <multi>
        <static>Shown.</static>
        <inverted-section name="nothin">
          <static>Also shown!</static>
        </inverted-section>
      </multi>
    </parseTree>
  </test>
  <test name="Empty Lists Inverted Sections" section="inverted-section">
    <template>{'Shown.
    {{^nothin}}
      Also shown!
    {{/nothin}}'}</template>
    <hash interpreter="json">{'{
      "nothin": []
    }'}</hash>
    <hash interpreter="xmlf"><nothin></nothin></hash>
    <hash interpreter="xmls"><entry name="nothin"></entry></hash>
    <output><div>Shown. Also shown!</div></output>
    <parseTree>
      <multi>
        <static>Shown.</static>
        <inverted-section name="nothin">
          <static>Also shown!</static>
        </inverted-section>
      </multi>
    </parseTree>
  </test>
  <test name="Non-empty Lists Inverted Sections" section="inverted-section">
    <template>{'Testing {{^repo}}
    <b>{{name}}</b>
  {{/repo}}'}</template>
    <hash interpreter="json">{'{
      "repo": [
        { "name": "resque" },
        { "name": "hub" },
        { "name": "rip" }
      ]
    }'}</hash>
    <hash interpreter="xmlf">
      <repo><name>resque</name></repo>
      <repo><name>hub</name></repo>
      <repo><name>rip</name></repo>
    </hash>
    <hash interpreter="xmls">
      <entry name="repo"><entry name="name">resque</entry></entry>
      <entry name="repo"><entry name="name">hub</entry></entry>
      <entry name="repo"><entry name="name">rip</entry></entry>
    </hash>
    <output><div>Testing</div></output>
    <parseTree>
      <multi>
        <static>Testing</static>
        <inverted-section name="repo">
          <static>&lt;b&gt;</static>
          <etag name="name"/>
          <static>&lt;/b&gt;</static>
        </inverted-section>
      </multi>
    </parseTree>
  </test>
  <test name="Comments"  section="comment">
    <template>{'<h1>Today{{! ignore me }}.</h1>'}</template>
    <hash interpreter="json">{'{}'}</hash>
    <hash interpreter="xmlf"></hash>
    <hash interpreter="xmls"></hash>
    <output><div><h1>Today.</h1></div></output>
    <parseTree>
      <multi>
        <static>&lt;h1&gt;Today</static>
        <comment>ignore me</comment>
        <static>.&lt;/h1&gt;</static>
      </multi>
    </parseTree>
  </test>
  <test name="After Taxes" section="complex">
    <template>{'Hello {{name}}! You have just won ${{value}}!
    {{#in_ca}} Well,
      ${{taxed_value}}, after taxes.
    {{/in_ca}}'}</template>
    <hash interpreter="json">{'{
      "name": "Chris",
      "value": 10000,
      "taxed_value": ' || 10000 - (10000 * 0.4) || ',
      "in_ca": true }'}</hash>
    <hash interpreter="xmlf"><name>Chris</name><value>10000</value><taxed_value>{ 10000 - (10000 * 0.4) }</taxed_value><in_ca>true</in_ca></hash>
    <hash interpreter="xmls">
      <entry name="name">Chris</entry>
      <entry name="value">10000</entry>
      <entry name="taxed_value">{ 10000 - (10000 * 0.4) }</entry>
      <entry name="in_ca">true</entry>
    </hash>
    <output><div>Hello Chris! You have just won $10000! Well, $6000, after taxes.</div></output>
    <parseTree>
      <multi>
        <static>Hello </static>
        <etag name="name"/>
        <static>! You have just won $</static>
        <etag name="value"/>
        <static>!</static>
        <section name="in_ca">
          <static>Well, $</static>
          <etag name="taxed_value"/>
          <static>, after taxes.</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="No Repos Inverted Sections" section="inverted-section">
    <template>{'{{#repo}}
      <b>{{name}}</b>
    {{/repo}}
    {{^repo}}
      No repos :(
    {{/repo}}'}</template>
    <hash interpreter="json">{'{
      "repo": []
    }'}</hash>
    <hash interpreter="xmlf"><repo></repo></hash>
    <hash interpreter="xmls"><entry name="repo"></entry></hash>
    <output><div>No repos :(</div></output>
    <parseTree>
      <multi>
        <section name="repo">
          <static>&lt;b&gt;</static>
          <etag name="name"/>
          <static>&lt;/b&gt;</static>
        </section>
        <static/>
        <inverted-section name="repo">
          <static>No repos :(</static>
        </inverted-section>
      </multi>
    </parseTree>
  </test>
  <test name="No Repos Inverted Sections with Inverted First" section="inverted-section">
    <template>{'{{^repo}}
        No repos :(
      {{/repo}}
      {{#repo}}
      <b>{{name}}</b>
    {{/repo}}
    '}</template>
    <hash interpreter="json">{'{
      "repo": []
    }'}</hash>
    <hash interpreter="xmlf"><repo></repo></hash>
    <hash interpreter="xmls"><entry name="repo"></entry></hash>
    <output><div>No repos :(</div></output>
    <parseTree>
      <multi>
        <inverted-section name="repo">
          <static>No repos :(</static>
        </inverted-section>
        <section name="repo">
          <static>&lt;b&gt;</static>
          <etag name="name"/>
          <static>&lt;/b&gt;</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Simple Whitespace" section="whitespace">
    <template>{'{{tag}} foo'}</template>
    <hash interpreter="json">{'{ "tag": "yo" }'}</hash>
    <hash interpreter="xmlf"><tag>yo</tag></hash>
    <hash interpreter="xmls"><entry name="tag">yo</entry></hash>
    <output><div>yo foo</div></output>
    <parseTree>
      <multi>
        <etag name="tag"/>
        <static>foo</static>
      </multi>
    </parseTree>
  </test>
  <test name="Descendant Extension" section="ext">
    <template>{'* {{*name}}'}</template>
    <hash interpreter="json">{'{
        "people": {
            "person": {
                "name": "Chris"
            },
            "name": "Jan"
        }
    }'}</hash>
    <hash interpreter="xmlf"><people><person><name>Chris</name></person><name>Jan</name></people></hash>
    <hash interpreter="xmls">
      <entry name="people">
        <entry name="person"><entry name="name">Chris</entry></entry>
        <entry name="name">Jan</entry>
      </entry>
    </hash>
    <output><div>* ChrisJan</div></output>
    <parseTree>
      <multi>
        <static>*</static>
        <rtag name="name"/>
      </multi>
    </parseTree>
  </test>
  <test name="Descendant Extension Inside Section" section="complex">
    <template>{'* {{#people}}{{#person}}{{*name}}{{/person}}{{/people}}'}</template>
    <hash interpreter="json">{'{
        "people": {
            "person": {
                "name": "Chris",
                "name": "Kelly"
            },
            "name": "Jan"
        }
    }'}</hash>
    <hash interpreter="xmlf"><people><person><name>Chris</name></person><person><name>Kelly</name></person><name>Jan</name></people></hash>
    <hash interpreter="xmls">
      <entry name="people">
        <entry name="person"><entry name="name">Chris</entry></entry>
        <entry name="person"><entry name="name">Kelly</entry></entry>
        <entry name="name">Jan</entry>
      </entry>
    </hash>
    <output><div>* ChrisKelly</div></output>
    <parseTree>
      <multi>
        <static>*</static>
        <section name="people">
          <section name="person">
            <rtag name="name"/>
          </section>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Dot Notation Sections" section="complex">
    <template>{'{{person.name}}'}</template>
    <hash interpreter="json">{'{ "person": {
      "name": "Chris",
      "company": "<b>GitHub</b>"
    } }'}</hash>
    <hash interpreter="xmlf"><person><name>Chris</name><company><b>GitHub</b></company></person></hash>
    <hash interpreter="xmls"><entry name="person"><entry name="name">Chris</entry><entry name="company"><b>GitHub</b></entry></entry></hash>
    <output><div>Chris</div></output>
    <parseTree>
      <multi>
        <section name="person">
          <etag name="name"/>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Nested Sections" section="complex">
    <template>{'{{#foo}}{{#a}}{{b}}{{/a}}{{/foo}}'}</template>
    <hash interpreter="json">{'{ "foo": [
      {"a": {"b": 1}},
      {"a": {"b": 2}},
      {"a": {"b": 3}}
    ] }'}</hash>
    <hash interpreter="xmlf">
      <foo><a><b>1</b></a></foo>
      <foo><a><b>2</b></a></foo>
      <foo><a><b>3</b></a></foo>
    </hash>
    <hash interpreter="xmls">
      <entry name="foo"><entry name="a"><entry name="b">1</entry></entry></entry>
      <entry name="foo"><entry name="a"><entry name="b">2</entry></entry></entry>
      <entry name="foo"><entry name="a"><entry name="b">3</entry></entry></entry>
    </hash>
    <output><div>123</div></output>
    <parseTree>
      <multi>
        <section name="foo">
          <static/>
          <section name="a">
            <etag name="b"/>
          </section>
          <static/>
        </section>
     </multi>
    </parseTree>
  </test>
  <test name="Welcome Joe" section="complex">
    <template>{'{{greeting}}, {{name}}!'}</template>
    <hash interpreter="json">{'{
      "name": "Joe",
      "greeting": "Welcome" }'}</hash>
    <hash interpreter="xmlf"><name>Joe</name><greeting>Welcome</greeting></hash>
    <hash interpreter="xmls"><entry name="name">Joe</entry><entry name="greeting">Welcome</entry></hash>
    <output><div>Welcome, Joe!</div></output>
    <parseTree>
      <multi>
        <etag name="greeting"/>
        <static>,</static>
        <etag name="name"/>
        <static>!</static>
      </multi>
    </parseTree>
  </test>
  <test name="Book with lots of nested Sections" section="complex">
    <template>{
      '{{#book}}
         {{#section}}
           {{#section}}
             {{#section}}
               {{p}}
             {{/section}}
           {{/section}}
{{/section}}
      {{/book}}'}</template>
    <hash interpreter="json">{'
      {"book": {"section": {"section": {"section": {"p": "Alive!"}}}}}'}</hash>
    <hash interpreter="xmlf">
      <book><section><section><section><p>Alive!</p></section></section></section></book>
    </hash>
    <hash interpreter="xmls">
      <entry name="book"><entry name="section"><entry name="section"><entry name="section"><entry name="p">Alive!</entry></entry></entry></entry></entry>
    </hash>
    <output><div>Alive!</div></output>
    <parseTree>
      <multi>
        <section name="book">
          <static/>
          <section name="section">
            <static/>
            <section name="section">
              <static/>
              <section name="section">
                <etag name="p"/>
              </section>
              <static/>
            </section>
            <static/>
          </section>
          <static/>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Colors Sample (Nested Sections)" section="complex">
    <template>{'<h1>{{header}}</h1>
    {{#bug}}
    {{/bug}}

    {{#items}}
      {{#first}}
        <li><strong>{{name}}</strong></li>
      {{/first}}
      {{#link}}
        <li><a href="{{url}}">{{name}}</a></li>
      {{/link}}
    {{/items}}

    {{#empty}}
      <p>The list is empty.</p>
    {{/empty}}
    '}</template>
    <hash interpreter="json">{'{
      "header": "Colors",
      "items": [
          {"name": "red", "first": true, "url": "#Red"},
          {"name": "green", "link": true, "url": "#Green"},
          {"name": "blue", "link": true, "url": "#Blue"}
      ],
      "empty": false
    }'}</hash>
    <hash interpreter="xmlf">
      <header>Colors</header>
      <items>
        <name>red</name>
        <first>true</first>
        <url>#Red</url>
      </items>
      <items>
        <name>green</name>
        <link>true</link>
        <url>#Green</url>
      </items>
      <items>
        <name>blue</name>
        <link>true</link>
        <url>#Blue</url>
      </items>
    </hash>
    <hash interpreter="xmls">
      <entry name="header">Colors</entry>
      <entry name="items">
        <entry name="name">red</entry>
        <entry name="first">true</entry>
        <entry name="url">#Red</entry>
      </entry>
      <entry name="items">
        <entry name="name">green</entry>
        <entry name="link">true</entry>
        <entry name="url">#Green</entry>
      </entry>
      <entry name="items">
        <entry name="name">blue</entry>
        <entry name="link">true</entry>
        <entry name="url">#Blue</entry>
      </entry>
    </hash>
    <output><div><h1>Colors</h1>
    <li><strong>red</strong></li>
    <li><a href="#Green">green</a></li>
    <li><a href="#Blue">blue</a></li></div></output>
    <parseTree>
      <multi>
        <static>&lt;h1&gt;</static>
        <etag name="header"/>
        <static>&lt;/h1&gt;</static>
        <section name="bug">
          <static/>
        </section>
        <static/>
        <section name="items">
          <static/>
          <section name="first">
            <static>&lt;li&gt;&lt;strong&gt;</static>
            <etag name="name"/>
            <static>&lt;/strong&gt;&lt;/li&gt;</static>
          </section>
          <static/>
          <section name="link">
            <static>&lt;li&gt;&lt;a href=&quot;</static>
            <etag name="url"/>
            <static>&quot;&gt;</static>
            <etag name="name"/>
            <static>&lt;/a&gt;&lt;/li&gt;</static>
          </section>
          <static/>
        </section>
        <static/>
        <section name="empty">
          <static>&lt;p&gt;The list is empty.&lt;/p&gt;</static>
        </section>
        <static/>
      </multi>
    </parseTree>
  </test>
  <test name="Section as Context" section="complex">
    <template>{'{{#a_object}}<h1>{{title}}</h1>
      <p>{{description}}</p>
      <ul>
        {{#a_list}}
        <li>{{label}}</li>
        {{/a_list}}
      </ul>{{/a_object}}'}</template>
    <hash interpreter="json">{'{
        "a_object": {
            "title": "this is an object",
            "description": "one of its attributes is a list",
            "a_list": [
                {
                    "label": "listitem1"
                },
                {
                    "label": "listitem2"
                }
            ]
        }
    }'}</hash>
    <hash interpreter="xmlf">
      <a_object>
        <title>this is an object</title>
        <description>one of its attributes is a list</description>
        <a_list>
          <label>listitem1</label>
        </a_list>
        <a_list>
          <label>listitem2</label>
        </a_list>
      </a_object>
    </hash>
    <hash interpreter="xmls">
      <entry name="a_object">
        <entry name="title">this is an object</entry>
        <entry name="description">one of its attributes is a list</entry>
        <entry name="a_list">
          <entry name="label">listitem1</entry>
        </entry>
        <entry name="a_list">
          <entry name="label">listitem2</entry>
        </entry>
      </entry>
    </hash>
    <output><div> <h1>this is an object</h1>
      <p>one of its attributes is a list</p>
      <ul>
            <li>listitem1</li>
            <li>listitem2</li>
        </ul></div></output>
    <parseTree>
      <multi>
        <section name="a_object">
          <static>&lt;h1&gt;</static>
          <etag name="title"/>
          <static>&lt;/h1&gt; &lt;p&gt;</static>
          <etag name="description"/>
          <static>&lt;/p&gt; &lt;ul&gt;</static>
          <section name="a_list">
            <static>&lt;li&gt;</static>
            <etag name="label"/>
            <static>&lt;/li&gt;</static>
          </section>
          <static>&lt;/ul&gt;</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Reuse of Enums" section="complex">
    <template>{'{{#terms}}
      {{name}}
      {{index}}
    {{/terms}}
    {{#terms}}
      {{name}}
      {{index}}
    {{/terms}}
    '}</template>
    <hash interpreter="json">{'{
      "terms": [
        {"name": "t1", "index": 0},
        {"name": "t2", "index": 1}
      ]
    }'}</hash>
    <hash interpreter="xmlf">
      <terms>
        <name>t1</name>
        <index>0</index>
      </terms>
      <terms>
        <name>t2</name>
        <index>1</index>
      </terms>
    </hash>
    <hash interpreter="xmls">
      <entry name="terms">
        <entry name="name">t1</entry>
        <entry name="index">0</entry>
      </entry>
      <entry name="terms">
        <entry name="name">t2</entry>
        <entry name="index">1</entry>
      </entry>
    </hash>
    <output><div>t1
    0
    t2
    1
    t1
    0
    t2
    1</div></output>
    <parseTree>
      <multi>
        <section name="terms">
          <etag name="name"/>
          <etag name="index"/>
        </section>
        <section name="terms">
          <etag name="name"/>
          <etag name="index"/>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Apos" section="complex">
    <template>{'{{apos}}{{control}}'}</template>
    <hash interpreter="json">{'{"apos": "&#39;", "control":"X"}'}</hash>
    <hash interpreter="xmlf">
      <apos>&#39;</apos>
      <control>X</control>
    </hash>
    <hash interpreter="xmls">
      <entry name="apos">&#39;</entry>
      <entry name="control">X</entry>
    </hash>
    <output><div>&#39;X</div></output>
    <parseTree>
      <multi>
        <etag name="apos"/>
        <etag name="control"/>
      </multi>
    </parseTree>
  </test>
  <test name="Recursion with Same Names" section="complex">
    <template>{'{{ name }}
    {{ description }}
    {{#terms}}
      {{name}}
      {{index}}
    {{/terms}}'}</template>
    <hash interpreter="json">{'
      {"name": "name",
      "description": "desc",
      "terms": [
        {"name": "t1", "index": 0},
        {"name": "t2", "index": 1} ] }'}</hash>
    <hash interpreter="xmlf">
      <name>name</name>
      <description>desc</description>
      <terms>
        <name>t1</name>
        <index>0</index>
      </terms>
      <terms>
        <name>t2</name>
        <index>1</index>
      </terms>
    </hash>
    <hash interpreter="xmls">
      <entry name="name">name</entry>
      <entry name="description">desc</entry>
      <entry name="terms">
        <entry name="name">t1</entry>
        <entry name="index">0</entry>
      </entry>
      <entry name="terms">
        <entry name="name">t2</entry>
        <entry name="index">1</entry>
      </entry>
    </hash>
    <output><div>name
        desc
          t1
          0
          t2
          1</div></output>
    <parseTree>
      <multi>
        <etag name="name"/>
        <etag name="description"/>
        <section name="terms">
          <etag name="name"/>
          <etag name="index"/>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Sequencial Mustaches" section="complex">
    <template>{'I like going to the {{location}} because I find it {{verb}}'}</template>
    <hash interpreter="json">{'{"location": "mall", "verb": "fun"}'}</hash>
    <hash interpreter="xmlf">
      <location>mall</location>
      <verb>fun</verb>
    </hash>
    <hash interpreter="xmls">
      <entry name="location">mall</entry>
      <entry name="verb">fun</entry>
    </hash>
    <output><div>I like going to the mall because I find it fun</div></output>
    <parseTree>
      <multi>
        <static>I like going to the</static>
        <etag name="location"/>
        <static>because I find it</static>
        <etag name="verb"/>
      </multi>
    </parseTree>
  </test>
  <test name="Dot Notation with Nested Sections" section="complex">
    <template>{'{{person.name.first}}'}</template>
    <hash interpreter="json">{'{ "person": {
      "name": {"first": "Chris"},
      "company": "<b>GitHub</b>"
    } }'}</hash>
    <hash interpreter="xmlf">
      <person>
        <name><first>Chris</first></name>
        <company><b>GitHub</b></company>
      </person>
    </hash>
    <hash interpreter="xmls">
      <entry name="person">
        <entry name="name"><entry name="first">Chris</entry></entry>
        <entry name="company"><b>GitHub</b></entry>
      </entry>
    </hash>
    <output><div>Chris</div></output>
    <parseTree>
      <multi>
        <section name="person">
          <section name="name">
            <etag name="first"/>
          </section>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Not Found" section="complex">
    <template>{'{{foo}}'}</template>
    <hash interpreter="json">{'{ "bar": "yo" }'}</hash>
    <hash interpreter="xmlf"><bar>yo</bar></hash>
    <hash interpreter="xmls"><entry name="bar">yo</entry></hash>
    <output><div/></output>
    <parseTree>
      <multi>
        <etag name="foo"/>
      </multi>
    </parseTree>
  </test>
  <test name="Simple delimiter switch" section="delimiter">
    <template>{'{{tag1}} is in normal angular brackets.
{{=<% %>=}}
<%tag2%> is in ERB style.'}</template>
    <hash interpreter="json">{'{
  "tag1": "Tag 1",
  "tag2": "Tag 2"
}'}</hash>
    <hash interpreter="xmlf">
      <tag1>Tag 1</tag1>
      <tag2>Tag 2</tag2>
    </hash>
    <hash interpreter="xmls">
      <entry name="tag1">Tag 1</entry>
      <entry name="tag2">Tag 2</entry>
    </hash>
    <output><div>Tag 1 is in normal angular brackets.

Tag 2 is in ERB style.</div></output>
    <parseTree>
	<multi>
	  <etag name="tag1"/>
	  <static> is in normal angular brackets.
	</static>
	  <static>
	</static>
	  <etag name="tag2"/>
	  <static> is in ERB style.
	</static>
	</multi>
    </parseTree>
  </test>
  <test name="Double delimiter switch" section="delimiter">
    <template>{'{{tag1}} is in normal angular brackets.
{{=<% %>=}}
<%tag2%> is in ERB style.
<%={{ }}=%>
{{tag3}} is in normal style again.'}</template>
    <hash interpreter="json">{'{
  "tag1": "Tag 1",
  "tag2": "Tag 2",
  "tag3": "Tag 3"
}'}</hash>
    <hash interpreter="xmlf">
      <tag1>Tag 1</tag1>
      <tag2>Tag 2</tag2>
      <tag3>Tag 3</tag3>
    </hash>
    <hash interpreter="xmls">
      <entry name="tag1">Tag 1</entry>
      <entry name="tag2">Tag 2</entry>
      <entry name="tag3">Tag 3</entry>
    </hash>
    <output><div>Tag 1 is in normal angular brackets.

Tag 2 is in ERB style.

Tag 3 is in normal style again.</div></output>
    <parseTree>
	<multi>
	  <etag name="tag1"/>
	  <static> is in normal angular brackets.
	</static>
	  <static>
	</static>
	  <etag name="tag2"/>
	  <static> is in ERB style.
	</static>
	  <static>
	</static>
	  <etag name="tag3"/>
	  <static> is in normal style again.
	</static>
	</multi>
    </parseTree>
  </test>
  <test name="Partial import" section="partial">
    <template>{'<h2>Names</h2>{{#names}}{{> partial_import.xq}}{{/names}}'}</template>
    <hash interpreter="json">{'{
	"names": [
	  { "name": "Peter" },
	  { "name": "Klaus" }
	]}'}
    </hash>
    <hash interpreter="xmlf">
      <names>
        <name>Peter</name>
      </names>
      <names>
        <name>Klaus</name>
      </names>
    </hash>
    <hash interpreter="xmls">
      <entry name="names"><entry name="name">Peter</entry></entry>
      <entry name="names"><entry name="name">Klaus</entry></entry>
    </hash>
    <output><div><h2>Names</h2>
  <strong>Peter</strong>
  <strong>Klaus</strong>
</div></output>
    <parseTree>
	<multi>
	  <static>&lt;h2&gt;Names&lt;/h2&gt;</static>
	  <section name="names">
	    <partial name="partial_import.xq"/>
	  </section>
	</multi>
    </parseTree>
  </test>
  <test name="Double partial import" section="partial">
    <template>{'<h2>Names</h2>{{#names}}{{> partial_import2.xq}}{{/names}}'}</template>
    <hash interpreter="json">{'{
	"names": [
	  { "name": "Peter" },
	  { "name": "Klaus" }
	]}'}
    </hash>
    <hash interpreter="xmlf">
      <names>
        <name>Peter</name>
      </names>
      <names>
        <name>Klaus</name>
      </names>
    </hash>
    <hash interpreter="xmls">
      <entry name="names"><entry name="name">Peter</entry></entry>
      <entry name="names"><entry name="name">Klaus</entry></entry>
    </hash>
    <output><div><h2>Names</h2>
  <h1><strong>Peter</strong></h1>
  <h1><strong>Klaus</strong></h1>
</div></output>
    <parseTree>
	<multi>
	  <static>&lt;h2&gt;Names&lt;/h2&gt;</static>
	  <section name="names">
	    <partial name="partial_import2.xq"/>
	  </section>
	</multi>
    </parseTree>
  </test>
  <test name="Parser Non-False Values" section="parser">
    <template>{'{{#person?}}
      Hi {{name}}!
    {{/person?}}'}</template>
    <parseTree>
      <multi>
        <section name="person?">
          <static>Hi</static>
          <etag name="name"/>
          <static>!</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Partial Recursion" section="parser">
    <template>{'{{name}}
    {{#kids}}
    {{>partial}}
    {{/kids}}'}</template>
    <parseTree>
      <multi>
        <etag name="name"/>
        <section name="kids">
          <partial name="partial"/>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Parser Simple Partial &gt;" section="parser">
    <template>{'Hello {{> world}}'}</template>
    <parseTree>
      <multi>
        <static>Hello</static>
        <partial name="world"/>
      </multi>
    </parseTree>
  </test>
  <test name="Parser Simple Comment" section="parser">
    <template>{'Hello World
      {{! author }}
      Nuno'}</template>
    <parseTree>
      <multi>
        <static>Hello World</static>
        <comment>author</comment>
        <static>Nuno</static>
      </multi>
    </parseTree>
  </test>
  <test name="Parser Triple Mustache" section="parser">
    <template>{'{{{world}}}'}</template>
    <parseTree>
      <multi>
        <utag name="world"/>
      </multi>
    </parseTree>
  </test>
  <test name="Parser Simple Lambda" section="parser">
    <template>{'{{#wrapped}}
      {{name}} is awesome.
    {{/wrapped}}'}</template>
    <parseTree>
      <multi>
        <section name="wrapped">
          <etag name="name"/>
          <static>is awesome.</static>
        </section>
      </multi>
    </parseTree>
  </test>
  <test name="Parser Partial Test" section="parser">
    <template>{'{{> next_more}}'}</template>
    <parseTree>
      <multi>
        <partial name="next_more"/>
      </multi>
    </parseTree>
  </test>
  <test name="Parser Template Partial" section="parser">
    <template>{'<h1>{{title}}</h1>
    {{>partial}}'}</template>
    <parseTree>
      <multi>
        <static>&lt;h1&gt;</static>
        <etag name="title"/>
        <static>&lt;/h1&gt;</static>
        <partial name="partial"/>
      </multi>
    </parseTree>
  </test>
<!--
      <test name="" section="">
        <template>{''}</template>
        <hash interpreter="json">{''}</hash>
        <hash interpreter="xmlf"></hash>
        <hash interpreter="xmls"></hash>
        <output><div></div></output>
        <parseTree>
          <multi/>
        </parseTree>
      </test>
-->
</tests>
