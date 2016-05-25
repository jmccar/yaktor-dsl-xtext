/*
 * generated by Xtext
 */
package io.yaktor.scoping

import io.yaktor.domain.ConstraintTypeField
import io.yaktor.domain.DomainModel
import io.yaktor.domain.Entity
import io.yaktor.domain.EnumType
import io.yaktor.domain.Field
import io.yaktor.domain.MongoNodeTableOptions
import io.yaktor.domain.NamedType
import io.yaktor.domain.TableType
import io.yaktor.domain.Type
import io.yaktor.domain.TypeField
import io.yaktor.mongoNode.Ttl
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider

import static org.eclipse.xtext.scoping.Scopes.*

import static extension io.yaktor.generator.nodejs.NodeJsExtensions.*

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#scoping
 * on how and when to use it 
 *
 */
class DomainScopeProvider extends AbstractDeclarativeScopeProvider {
  def scope_TableType_keys(TableType type, EReference ref) {
    scopeFor(type.allFields)
  }

  def scope_ConstraintTypeField(TableType type, EReference ref) {
    var allfields=  type.allFields
    switch (type) {
      Entity: allfields.addAll(type.associationEnds.opposites)
    }
    
    scopeFor(allfields.filter(ConstraintTypeField))
  }

  def <T extends NamedType> IScope scopeFor(DomainModel dm, Class<T> type, IScope s) {
    var scope = s ?: IScope.NULLSCOPE
    scope = scopeFor(dm.eContents.filter(type), scope)
    for (odm : dm.domainModelImports) {
      if(odm.ref != null){
        scope = scopeFor(odm.ref.eContents.filter(type),
          [elem|QualifiedName.create(odm.alias ?: odm.ref.name?:"none").append(elem.name?:"none")], scope)
      }
    }
    return scope
  }
  def scope_DateField(Ttl ttl, EReference ref){
    var oType = (ttl.eContainer as MongoNodeTableOptions).type
    if(oType != null){
      oType.fieldsReachableFields(QualifiedName.EMPTY,IScope.NULLSCOPE,Field)
    } else {
      IScope.NULLSCOPE
    }
  }
  def scope_ConstraintTypeField(Entity oType, EReference ref){
    oType.fieldsReachableFields(QualifiedName.EMPTY,IScope.NULLSCOPE,ConstraintTypeField)
  }
  def <T extends Field> IScope fieldsReachableFields(TableType oType,QualifiedName base,IScope parent,Class<T> filterType){
      var scope = parent
      for( type : oType.allFields.filter(TypeField)){
        if(!type.many){
          scope = type.isType.fieldsReachableFields(base.append(type.name),scope,filterType)
        }
      }
      return scopeFor(oType.allFields.filter(filterType),[f|base.append(f.name?:"")],scope)
  }

  def scope_TableType(DomainModel dm, EReference ref) {
    dm.scopeFor(TableType, null);
  }

  def scope_Type(DomainModel dm, EReference ref) {
    dm.scopeFor(Type, null);
  }

  def scope_NamedType(DomainModel dm, EReference ref) {
    dm.scopeFor(NamedType, null);
  }

  def scope_EnumType(DomainModel dm, EReference ref) {
    dm.scopeFor(EnumType, null);
  }

  def scope_Entity(DomainModel dm, EReference ref) {
    dm.scopeFor(Entity, null);
  }
}
