/*
 * generated by Xtext
 */
package io.yaktor.scoping

import com.google.inject.Inject
import io.yaktor.access.RestService
import io.yaktor.access.Service
import io.yaktor.access.View
import io.yaktor.conversation.Agent
import io.yaktor.conversation.Conversation
import io.yaktor.conversation.Decision
import io.yaktor.conversation.Event
import io.yaktor.conversation.PublishableByMe
import io.yaktor.conversation.PublishableByOthers
import io.yaktor.conversation.State
import io.yaktor.conversation.SubscribableByOthers
import io.yaktor.conversation.Transition
import io.yaktor.conversation.TypeImport
import io.yaktor.conversation.impl.AgentImpl
import io.yaktor.types.MappedField
import io.yaktor.types.NewField
import io.yaktor.types.Projection
import io.yaktor.types.ProjectionField
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleLocalScopeProvider

import static org.eclipse.xtext.scoping.Scopes.*

import static extension io.yaktor.generator.js.JsTypesExtensions.*

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#scoping
 * on how and when to use it 
 *
 */
class ConversationScopeProvider extends AbstractDeclarativeScopeProvider {
  @Inject
  private var IGlobalScopeProvider globalScopeProvider;
  @Inject
  private var SimpleLocalScopeProvider localScopeProvider;

  private var projectionNameResolver = [Projection p|QualifiedName.create(p.name ?: "")];

  // From the View get me some RestService
  def scope_RestService(View view, EReference reference) {
    var c = view.eContainer as Conversation
    scopeFor(c.restServices, [rs|QualifiedName.create(rs.url?:"NO_URL")], IScope.NULLSCOPE)
  }


  def scope_Projection(TypeImport context, EReference reference) {
    globalScopeProvider.getScope(context.eResource, reference, null)
  }

  def scope_Projection(RestService context, EReference reference) {
    localScopeProvider.getScope(context, reference)
  }

  def scope_Projection(Service context, EReference reference) {
    localScopeProvider.getScope(context, reference)
  }

  // Basically you can only reference Projections from the context of an agent either 
  def scope_Projection(Agent agent, EReference reference) {
    var scope = scopeFor(agent.definedTypes, projectionNameResolver, IScope.NULLSCOPE)
    for (otherAgent : agent.parent.agents.filter[otherAgent|otherAgent != agent]) {
      scope = scopeFor(otherAgent.definedTypes,
        [projection|QualifiedName.create(otherAgent.name).append(projectionNameResolver.apply(projection))],
        scope)
    }
    scope = scopeFor(agent.parent.definedTypes, projectionNameResolver, scope)
    return agent.parent.importedTypes.fold(scope,
      [ iscope, depend |
        if (depend.type != null) {
          scopeFor(#[depend.type],
            [Projection proj|QualifiedName.create(depend.alias ?: depend.type.name ?: "")], iscope)
        } else {
          iscope
        }
      ])
  }

  // From the Projection get me some Fields
  def scope_Field(Projection projection, EReference reference) {
    if (projection.entity != null || projection.parent != null) {
      scopeFor(projection.superAllFields)
    } else {
      IScope.NULLSCOPE
    }
  }

  def scope_ProjectionField(Transition t, EReference reference) {
    var causedBy = t.exCausedBy?:t.causedBy
    if (causedBy == null) {
      IScope.NULLSCOPE
    } else {
      var scope = IScope.NULLSCOPE
      var type = causedBy.refType
      if (type != null) {
        scope = type.fieldScopeForType(scope, QualifiedName.create(type.name))
      }
      scope;
    }
  }

  def IScope fieldScopeForType(Projection type, IScope scope, QualifiedName name) {
    var fields = type.allProjectionFields
    var newScope = scopeFor(
      fields.filter[field|
        switch (field) {
          MappedField case field.projection == null: true
          NewField: true
          default: false
        }],
      [ ProjectionField field |
        QualifiedName.create(name.segments).append(field.resolve.name)
      ], scope)
    for (field : fields.filter(MappedField)) {
      if (field.projection != null) {
        newScope = field.projection.fieldScopeForType(newScope,
          QualifiedName.create(name.segments).append(field.name))
      }
    }
    return newScope;
  }

  // From the Projection get me some TableType
  def scope_Entity(Projection field, EReference reference) {
    return globalScopeProvider.getScope(field.eResource, reference, null)
  }

  def scope_Agent(AgentImpl context, EReference reference) {
    globalScopeProvider.getScope(context.eResource, reference, null);
  }

  def scope_Transition_exCausedBy(State context, EReference reference) {
    if (!(context instanceof Decision)) {
      doStateEvent(context, SubscribableByOthers)
    } else {
      IScope.NULLSCOPE
    }
  }

  def scope_Transition_toState(Transition context, EReference reference) {
    var state = context.eContainer as State
    var fsm = state.parent;
    scopeFor(fsm.states)
  }

  def scope_Transition_triggers(State state, EReference reference) {
    var fsm = state.parent;
    var agent = fsm.parent;
    scopeFor(agent.sendables.filter(PublishableByMe))
  }

  def scope_Transition_exTriggers(State context, EReference reference) {
    doStateEvent(context, PublishableByOthers)
  }

  def doTransitionEvent(Transition context, Class<? extends Event> filterClass) {
    var state = context.eContainer as State
    doStateEvent(state, filterClass)
  }

  def doStateEvent(State state, Class<? extends Event> filterClass) {
    var fsm = state.parent;
    val agent = fsm.parent
    var IScope scope
    for (dependency : agent.parent.importedAgents) {
      scope = dependency.agent.scopeForAgent(dependency.alias, scope, filterClass)
    }
    for (otherAgent : agent.parent.agents.filter[a|a != agent]) {
      scope = otherAgent.scopeForAgent(otherAgent.name, scope, filterClass)
    }

    return scope ?: IScope.NULLSCOPE
  }

  def scopeForAgent(Agent agent, String alias, IScope parent, Class<? extends Event> filterClass) {
    scopeFor(agent.sendables.filter(filterClass),
      [ EObject eObj |
        var event = eObj as Event;
        return QualifiedName.create(alias ?: agent.name?: "").append(event.name);
      ], parent ?: IScope.NULLSCOPE)

  }
}
