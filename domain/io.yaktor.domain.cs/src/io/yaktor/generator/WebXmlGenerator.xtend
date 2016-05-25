package io.yaktor.generator

import com.google.inject.Inject
import io.yaktor.domain.DomainModel
import io.yaktor.domain.InclusionType
import io.yaktor.domain.JpaGenOptions
import io.yaktor.util.Constants
import io.yaktor.util.DslDomainUtil
import io.yaktor.util.FileUtil
import io.yaktor.util.InclusionCat
import org.eclipse.xtext.generator.IFileSystemAccess

class WebXmlGenerator {

  @Inject extension FileUtil fileUtil
  @Inject extension DslDomainUtil dslDomainUtil

  
  def genWebXml(IFileSystemAccess fsa, DomainModel spec) {
    var inc = spec.getInclusionType(InclusionCat::WEBXML)
    if (inc != InclusionType::NONE) {
	  	fileUtil.generateFile(fsa, Constants::webInfBase, '', 'web.xml', spec.genWebXml(), inc == InclusionType::PROTECTED)
	}
  }


  def genWebXml(DomainModel spec) {'''
	<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
	<web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.5" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd">
	
	    <display-name>«(spec.genOptions as JpaGenOptions).project.name»</display-name>
	    
	    <description>DSL Domain generated «(spec.genOptions as JpaGenOptions).project.name» application</description>
	
	    <!-- Enable escaping of form submission contents -->
	    <context-param>
	        <param-name>defaultHtmlEscape</param-name>
	        <param-value>true</param-value>
	    </context-param>
	    
	    <context-param>
	        <param-name>contextConfigLocation</param-name>
	        <param-value>classpath*:META-INF/spring/applicationContext*.xml</param-value>
	    </context-param>
	    
	    <filter>
	        <filter-name>CharacterEncodingFilter</filter-name>
	        <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
	        <init-param>
	            <param-name>encoding</param-name>
	            <param-value>UTF-8</param-value>
	        </init-param>
	        <init-param>
	            <param-name>forceEncoding</param-name>
	            <param-value>true</param-value>
	        </init-param>
	    </filter>
	    
	    <filter>
	        <filter-name>HttpMethodFilter</filter-name>
	        <filter-class>org.springframework.web.filter.HiddenHttpMethodFilter</filter-class>
	    </filter>
	    
	    <filter>
	        <filter-name>Spring OpenEntityManagerInViewFilter</filter-name>
	        <filter-class>org.springframework.orm.jpa.support.OpenEntityManagerInViewFilter</filter-class>
	    </filter>
	    <filter-mapping>
	        <filter-name>CharacterEncodingFilter</filter-name>
	        <url-pattern>/*</url-pattern>
	    </filter-mapping>
	    
	    <filter-mapping>
	        <filter-name>HttpMethodFilter</filter-name>
	        <url-pattern>/*</url-pattern>
	    </filter-mapping>
	    
	    <filter-mapping>
	        <filter-name>Spring OpenEntityManagerInViewFilter</filter-name>
	        <url-pattern>/*</url-pattern>
	    </filter-mapping>
	    
	    <!-- Creates the Spring Container shared by all Servlets and Filters -->
	    <listener>
	        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
	    </listener>
	    
	    <!-- Handles Spring requests -->
	    <servlet>
	        <servlet-name>«(spec.genOptions as JpaGenOptions).project.name»</servlet-name>
	        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
	        <init-param>
	            <param-name>contextConfigLocation</param-name>
	            <param-value>WEB-INF/spring/webmvc-config.xml</param-value>
	        </init-param>
	        <load-on-startup>1</load-on-startup>
	    </servlet>
	    
	    <servlet-mapping>
	        <servlet-name>«(spec.genOptions as JpaGenOptions).project.name»</servlet-name>
	        <url-pattern>/</url-pattern>
	    </servlet-mapping>
	    
	    <session-config>
	        <session-timeout>10</session-timeout>
	    </session-config>
	    
	    <error-page>
	        <exception-type>java.lang.Exception</exception-type>
	        <location>/uncaughtException</location>
	    </error-page>
	    
	    <error-page>
	        <error-code>404</error-code>
	        <location>/resourceNotFound</location>
	    </error-page>
	</web-app>

    '''
  }
}
