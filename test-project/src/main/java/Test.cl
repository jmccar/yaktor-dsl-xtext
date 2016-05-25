conversation Test {
  type Test from Test.All {
  }
  type TestRef from Test.Ref {
    a
    i {
      a
    }
  }
  agent Test concerns Test {
    receives finished
    sends started: Test
    privately receives ^start: Test

    initially receives ^start -> working > started
    {
      done {
      }
      working {
        finished -> done
      }
    }
  }
  agent TestDepend concerns Test {
    privately receives error
    privately receives done

    initially receives Test.started -> thinking
    {
      broken {
      }
      done {
      }
      decision thinking {
        done -> done > Test.finished
        error -> broken
      }
    }
  }

  type B from Test.B {}
  type C from Test.C {
    id
    a
    c
    ShortId y "(\\w)*"
    String p pattern "(\\w)*"
  }

  view /test.vw over /test
  resource /test for Test.Test offers ( create read update delete ) interchanges ( json form )
  
  
  view /c over /c
  resource /c for Test.C offers ( create read update delete ) interchanges ( json form )
  view /b over /b
  resource /b for Test.B offers ( create read update delete ) interchanges ( json form )
  
  view /TestRef over /TestRef
  resource /TestRef for Test.TestRef offers ( create read update delete ) interchanges ( json form )

}
