//
//  Tree.hpp
//  multiTree
//
//  Created by Dismukes, Wade T [EEOBS] on 11/7/17.
//  Copyright © 2017 Dismukes, Wade T [EEOBS]. All rights reserved.
//

#ifndef Tree_h
#define Tree_h

#include <string>
#include <vector>
#include <iostream>
#include <RcppArmadillo.h>

using namespace Rcpp;

class Node
{
    private:
        Node    *ldes;
        Node    *rdes;
        Node    *anc;
        Node    *sib;
        int     indx, Lindx;
        std::vector<int> hosts;
        int     flag;
        std::string name;
        bool    isRoot;
        bool    isTip;
        bool    isExtant, isExtinct;
        bool    isDuplication;
        double  birthTime, deathTime;
        double  branchLength;
        int     locusID;

    public:
                Node();
                ~Node();
        void    setAsRoot(bool t) {isRoot = t; }
        void    setBirthTime(double bt) {birthTime = bt; }
        void    setIndx(unsigned i) {indx = i; }
        void    setIsTip(bool t) {isTip = t; }
        void    setDeathTime(double dt) {deathTime = dt; }
        void    setIsExtant(bool t) {isExtant = t; }
        void    setIsExtinct(bool t) {isExtinct = t; }
        void    setLdes(Node *l) {ldes = l; }
        void    setRdes(Node *r) {rdes = r; }
        void    setAnc(Node *a) {anc = a; }
        void    setSib(Node *s) {sib = s; }
        void    setName(std::string f) { name = f; }
        void    setBranchLength(double bl) {branchLength = bl; }
        void    setFlag(int d) { flag = d; }
        void    setIndx(int i) {indx = i; }
        void    setLindx(int li ) {Lindx = li; }
        void    addHost(int hostIndx) { hosts.push_back(std::move(hostIndx)); }
        void    setIsDuplication(bool t) { isDuplication = t; }
        void    setLocusID(int a) { locusID = a; }
        int     getFlag() {return flag; }
        Node*   getLdes() {return ldes; }
        Node*   getRdes() {return rdes; }
        Node*   getAnc() {return anc; }
        Node*   getSib() {return sib; }
        bool    getIsRoot() {return isRoot; }
        bool    getIsTip() {return isTip; }
        bool    getIsExtinct() {return isExtinct; }
        bool    getIsExtant() { return isExtant; }
        std::string getName() { return name; }
        double  getBranchLength() { return branchLength; }
        double  getDeathTime() {return deathTime; }
        double  getBirthTime() { return birthTime; }
        int     getIndex() {return indx; }
        int     getLindx() { return Lindx; }
        std::vector<int> getHosts() { return hosts; }
        void    setHosts(std::vector<int> hs) { hosts = hs; }
        bool    getIsDuplication() { return isDuplication; }
        int     getLocusID() { return locusID; }
};



class Tree
{
    protected:
        Node    *root;
        Node    *extantRoot;
        Node    *outgrp;
        std::vector<Node*> nodes;
        std::vector<Node*> extantNodes;
        unsigned numTaxa, numNodes, numTotalTips;
        unsigned numExtant, numExtinct;
        double  currentTime;
        std::vector<double> branchLengths;

    public:
                    Tree(unsigned numExtant, double cTime);
                    Tree(unsigned numTaxa);
                    Tree(SEXP rtree);
        virtual      ~Tree();
        void        setOutgroup(Node *og) { outgrp = og; }
        Node*       getOutgroup() { return outgrp; }
        Node*       getRoot() {return root; }
        Node*       getExtantRoot() { return extantRoot; }
        void        setExtantRoot(Node *r) { extantRoot = r; }
        void        setRoot(Node *r) { root = r; }
        double      getNumExtant() {return numExtant; }
        int         getNumTips() { return extantNodes.size(); }
        double      getNumExtinct() {return numExtinct; }
        int         getNodesSize() { return (int) nodes.size(); }
        double      getTotalTreeLength();
        double      getTreeDepth();
        double      getCurrentTime() {return currentTime; }
        double      getEndTime();
        void        setNumExtant();
        void        setNumExtinct();
        void        rescaleTreeByOutgroupFrac(double outgroupFrac,
                                              double getTreeDepth);
        void        clearNodes(Node *cur);
        void        zeroAllFlags();
        void        setWholeTreeFlags();
        void        setExtantTreeFlags();
        void        setSampleFromFlags();
        void        getRootFromFlags(bool isGeneTree = false);
        void        getExtantTree();
        void        setNewRootInfo(Node *newRoot,
                                   Node *outgroup,
                                   Node *oldRoot,
                                   double t);
        std::vector<Node*> getNodes() { return nodes; }
        std::vector<Node*> getExtantNodes() { return extantNodes; }
        void        scaleTree( double treeScale , double currtime);
        void        reconstructTreeFromSim(Node *oRoot);
        void        reconstructLineageFromSim(Node *currN,
                                              Node *prevN,
                                              unsigned &tipCounter,
                                              unsigned &intNodeCounter);


        void        reindexForR();
        std::vector<std::string>    getTipNames();
        std::vector<std::string>    getNodeLabels();
        NumericMatrix getEdges();
        std::vector<double> getEdgeLengths();
        int         getNnodes() { return (int) nodes.size() - (numExtant + numExtinct);}
        void        setTipsFromRtree();
        double      findMaxNodeHeight();
        int         getIndexFromNodes(int indx) {return nodes[indx]->getIndex(); }
        void        switchIndicesFirstToSecond(std::map<int,int> mappy);
        virtual double  getTimeToNextEvent() { return 0.0; }
        virtual void    lineageBirthEvent(unsigned int indx) { return; }
        virtual void    lineageDeathEvent(unsigned int indx) { return; }
        virtual void    setTreeTipNames()  { return; }
        virtual void    ermEvent(double ct) { return; }
        virtual void    setBranchLengths() { return; }
        virtual int     calculatePatristicDistance(Node *n1, Node *n2);
        friend class Node;

};
#endif /* Tree_hpp */
